window.tools = _.extend window.tools || {}, BookmarksView: null

class window.tools.BookmarksView extends Backbone.View
    _instance = null
    _template = null
    _beginTop = 0

    collection: null
    parent: null
    bookmarks: []
    animationTime: 300
    isOpen: no
    isShow: no

    constructor: (args...) ->
        _template = _.template """
            <div class="bookmark-view">
                <div class="bookmark_view-widget">
                    <div class="fa fa-star left"></div>
                    <div class="bookmark_view-count left">{{{count}}}</div>
                </div>
                <div class="bookmark_view-box">
                    {[ _.each(bookmarks, function(bookmark){ ]}
                        {{bookmark}}
                    {[ }); ]}
                </div>
            </div>
        """
        @bookmarks = []
        @collection = new BookmarkCollection
        _.extend @, args[0]
        super args...

    initialize: =>
        @collection.fetch()
        @render()
        @show() if @collection.length
        @collection.on 'add', @render
        @collection.on 'remove', @render
        $(window).scroll (e) => @$el.css 'top', parseInt($(window).scrollTop()) + _beginTop if @$el?

    events: => 'click .bookmark_view-count': '_displayToggle'

    add: (icon, name, url) =>
        model = new BookmarkModel icon: icon, name: name, bookmark: url
        @collection.add model
        model.save()
             .done => @_append model

    remove: (url) =>
        model = @find url
        model.destroy() if model?

    find: (url) => @collection.findWhere bookmark: url if @collection?

    show: =>
        if @parent? and !@isShow
            $.when @$el.css('opacity': 0).appendTo @parent.$el
             .then => _beginTop = parseInt @$el.css('top') if not _beginTop
             .done =>
                @$el.animate 'opacity': 1, @animationTime
                @isShow = yes

    hide: =>
        if @parent?
            @$el.animate 'opacity': 0, @animationTime, =>
                @close()
                @$el.detach()
                @isShow = no

    open: =>
        if @$el?
            @$el.find('.bookmark_view-box')
                .show()
            @isOpen = yes

    close: =>
        if @$el?
            @$el.find('.bookmark_view-box')
                .hide()
            @isOpen = no

    render: =>
        if not @$el.hasClass 'bookmark-view'
            @$el = $ _template count: @collection.length, bookmarks: []
            @el = @$el.get 0
            @collection.each @_append
        @$el.find '.bookmark_view-count'
            .html @collection.length
        @show() if @collection.length is 1
        @hide() if @collection.length is 0

    _displayToggle: => if @isOpen then @close() else @open()

    _append: (model) =>
        @bookmarks.push new BookmarkView model: model
        @$el.find '.bookmark_view-box'
            .append _.last(@bookmarks).render()

    @getBookmarks: (args...) -> if not _instance? then _instance = new @ args... else _instance

$ -> main.bookmark = tools.BookmarksView.getBookmarks parent: main.view if main.bookmark is null


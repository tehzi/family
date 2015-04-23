class ComicsView extends Backbone.View
    _bookmarkAddClass = 'bookmark-adder'
    _bookmarkActiveAddClass = 'bookmark_adder-active'
    _loading    = $ '<div class="loading"></div>'
    _leftArrow  = null
    _rightArrow = null
    _instance = null
    _firstTime = yes

    selector: null
    loader: null
    route: null
    parent: null
    page: 1
    lastPage: 0
    $currentStrip: null
    animateTime: 200
    name: ""
    id: 0
    base: ""
    pushstate: false
    bookmarkIcon: null

    constructor: (args...) ->
        @selector = ui    and new ui.ComicsSelector '#comics-toolbar', '[data-plagin="select2"]'
        @loader   = tools and new tools.LoadingBox '.loading-box:eq(0)'
        @page = parseInt $('body').data 'current_page'
        @lastPage = parseInt $('body').data 'last_page'
        @name = $('body').data 'comic_name'
        @id = $('body').data 'comic_id'
        @base = $('body').data 'base'
        @pushstate = $('body').data('pushstate') and Modernizr and Modernizr.history
        @bookmarkIcon = $('body').data 'bookmark_icon'
        @route = new ComicsRoute @
        _.extend @, args[0]
        super args...

    initialize: =>
        _leftArrow  = @.$el.find '.comics_left-arrow'
        _rightArrow = @.$el.find '.comics_right-arrow'
        @$currentStrip = @$el.find '.comics-box img'
        @selector.value @page
        bookmark = if main.bookmark? then main.bookmark else tools.BookmarksView.getBookmarks parent: @
        if bookmark?
            bookmark.collection.on 'add', @_setBookmark
            bookmark.collection.on 'remove', (model) => @_unsetBookmark() if model.get('bookmark') is location.href
            @_setBookmark() if bookmark.find location.href
        Backbone.history.start
            pushState: @pushstate
            hashChange: !@pushstate
            root: @base
        @showTooltip() if @$el.find('.comics-box img').get(0).complete
        $(".#{_bookmarkAddClass}").bind
            'mouseenter': -> $(this).stop().animate top: 0, 1000
            'mouseleave': -> $(this).stop().animate top: -50, 1000

    events: =>
        $(@selector).on 'go', @_selectSlide
        $(@loader).on 'start', @_loadStart
        $(@loader).on 'end', @_loadEnd
        @$el.find('.comics-box img').on 'load', @_loadEnd
        $(window).keypress @_keyBind
        'click .comics_left-arrow': '_prev'
        'click .comics_right-arrow': '_next'
        'click .bookmark-adder': '_toggleBookmark'

    setSlide: (slide) =>
        slide = parseInt slide
        @selector.value @page
        $('#comics-current_page').text @page
        if @page != slide
            @page = parseInt slide
            $.ajax type: "GET", url: "/rest/comics/#{@id}/strip/#{slide}"
             .done (r) => @_done r.page, r.url
             .fail (r) => @_error r

    addBookmark: =>
        if @parent.bookmark?
            @parent.bookmark.add @bookmarkIcon, "#{@name}, страница: #{@page}", location.href
            @_setBookmark()

    removeBookmark: =>
        if @parent.bookmark?
            @parent.bookmark.remove location.href
            @_unsetBookmark()

    showTooltip: =>
        if @parent? and @parent.tooltip? and _firstTime
            @parent.tooltip.show()
            _firstTime = no
        else if _firstTime and window.tools
            tools.TooltipsView.getTooltip()
                              .show()

    _keyBind: (e) =>
        console.log e.keyCode
        @_prev() if e.keyCode is 37 and @page > 1
        @_next() if e.keyCode is 39 and @page < @lastPage
        $(window).off 'keypress', @_keyBind
        setTimeout (=> $(window).keypress @_keyBind), 400

    _toggleBookmark: => if not @$el.find(".#{_bookmarkAddClass}").hasClass _bookmarkActiveAddClass then @addBookmark() else @removeBookmark()

    _setBookmark: =>   @$el.find(".#{_bookmarkAddClass}").addClass    _bookmarkActiveAddClass

    _unsetBookmark: => @$el.find(".#{_bookmarkAddClass}").removeClass _bookmarkActiveAddClass

    _prev: =>
        @_hide()
        $.ajax type: "GET", url: "/strip/prev/#{@page}"
         .done (r) =>
            @page = r.prev
            @_done r.prev, r.url
         .fail (r) => @_error

    _next: =>
        @_hide()
        $.ajax type: "GET", url: "/strip/next/#{@page}"
         .done (r) =>
            @page = r.next
            @_done r.next, r.url
         .fail (r) => @_error r

    _selectSlide: (e, slide) => @setSlide slide

    _loadStart: (e) =>
        _loading.css     opacity: 0
                .animate opacity: 1, @animateTime * 4
        @$currentStrip.parents '.comics-box'
                      .append _loading

    _loadEnd: (e) =>
        @showTooltip()
        _loading.remove()
        @_show()

    _hide: =>
        comics_box = @$currentStrip.parents '.comics-box'
        width = comics_box.width()
        height = parseInt(comics_box.height()) + parseInt(comics_box.css('padding-top')) + parseInt(comics_box.css('padding-bottom'))
        comics_box.css width: width, height: height
        @$currentStrip.animate opacity: 0, @animateTime

    _show: =>
        comics_box = @$currentStrip.parents '.comics-box'
        @loader.setAlt "#{@name}, strip #{@page}"
        image = @loader.getImage()
        if image?
            image.css opacity: 0
            @$currentStrip.replaceWith image
            comics_box.css width: 'auto', height: 'auto'
            image.animate opacity: 1, @animateTime, => @loader.reset()
            @$currentStrip = image

    _error: (r) => tools.TooltipsView.error "Ошибка загрузки", r.error

    _done: (page, url) =>
        try
            @setSlide page
            @loader.setImage url
            _leftArrow[ 'fade' + if @page > 1 and @lastPage >= @page then 'In' else 'Out'] @animateTime
            _rightArrow['fade' + if @page != @lastPage               then 'In' else 'Out'] @animateTime
            @route.navigate "strip/#{@page}", trigger: true
            if @parent.bookmark.find location.href then @_setBookmark() else @_unsetBookmark()
            tools.TooltipsView.errorClose() if tools? and tools.TooltipsView?
            yes
        catch _err then no

    @getComicsView: (args...) -> if not _instance? then _instance = new @ args... else _instance

$ -> window.main.view = ComicsView.getComicsView parent: window.main, el: '.main-comic_page'


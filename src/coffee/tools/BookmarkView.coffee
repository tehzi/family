class BookmarkView extends Backbone.View
    _template = null

    constructor: (args...) ->
        _template = _.template """
            <div class="bookmark_view-item">
                <div class="left bookmark_view_image-wrapper">
                    <a href="{{{href}}}"><img src="{{src}}" alt="{{alt}}"></a>
                </div>
                <div class="bookmark_view-wrapper">
                    <div class="bookmark_view-name"><a href="{{{href}}}">{{{name}}}</a></div>
                    <div class="bookmark_view-date">{{{date}}}</div>
                </div>
                <a href="javascript:void(0)" class="bookmark_view-remove fa fa-times"></a>
            </div>
        """
        super args...

    initialize: =>
        @model.on 'remove', @remove
        @render()

    events: => 'click .bookmark_view-remove': 'remove'

    remove: =>
        @model.destroy() if @model?
        @$el.remove()

    render: =>
        if not @$el.hasClass 'bookmark_view-item'
            date = new Date @model.get 'date'
            date = "0#{date.getDate()}".slice(-2) + "." + "0#{date.getMonth() + 1}".slice(-2) + ".#{date.getFullYear()}"
            @$el = $ _template
                src:  @model.get 'icon'
                alt:  @model.get 'name'
                name: @model.get 'name'
                href: @model.get 'bookmark'
                date: date
            @el = @$el.get 0
        @$el


class TooltipView extends Backbone.View
    _template = null
    parent: null
    $parent: null,
    timeToClose: 10000

    constructor: (args...) ->
        _template = _.template """
            <div class="tooltip-view">
                <div class="tooltip_view-close fa fa-times"></div>
                <div class="tooltip_view-title">{{{title}}}</div>
                <div class="tooltip_view-content">{{{content}}}</div>
            </div>
        """
        super args...
        _.extend @, args[0]
        if @parent? then @$parent = $ @parent

    initialize: =>
        @el = _template title: @model.get('title'), content: @model.get('tip')
        @$el = $ @el

    events: => 'click .tooltip_view-close': 'close'

    autoshow: => @model.get 'autoshow'

    show: => if @autoshow() then @render()

    render: =>
        [offset, top, left] = []
        $.when  @$el.css(opacity: 0).appendTo 'body'
         .then =>
            @_ieOldAdditionalRender() if $('html').hasClass('lte8')
            offset = @$parent.offset()
            top =  offset.top  + @$parent.height() + parseInt @$el.css 'margin-top'
            left = offset.left + parseInt @$el.css 'margin-left'
         .done => @$el.css(top: top, left: left).animate opacity: 1, 1300, => setTimeout @_close, @timeToClose

    close: =>
        @model.set 'autoshow', no
        @model.save()
        @_close()

    _close: =>
        @$el.animate opacity: 0, 300

    _ieOldAdditionalRender: =>
        @$el.prepend '<div class="triangle-up"></div>'


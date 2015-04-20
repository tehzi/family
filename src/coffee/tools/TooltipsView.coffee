window.tools = _.extend window.tools || {}, TooltipsView: null

class window.tools.TooltipsView extends Backbone.View
    _tooltip = null
    _error = null

    @collection: null
    tooltips: []

    constructor: (options) ->
        @collection = new TooltipCollection
        @tooltips = []
        super options

    initialize: =>
        @collection.fetch()
        $('[data-toggle="tooltip-view"]').each (index, element) =>
            $element = $ element
            mark = $element.data 'mark'
            model = @collection.findWhere mark: mark
            if not model?
                modelParams =
                    mark: mark
                    title:    $element.data 'title'
                    tip:      $element.attr 'title'
                    autoshow: $element.data 'autoshow'
                model = new TooltipModel _.extend {}, TooltipModel::defaults, modelParams
                @collection.add model
                model.save()
            @tooltips.push new TooltipView model: model, parent: element

    show: => _.each @tooltips, (element) => element.show()

    @getTooltip: => if _tooltip is null then _tooltip = new @ else _tooltip

    @error: (title, error) ->
        _error.remove() if _error?
        _error_template = _.template """
            <div class="tooltip_view-error">
                <div class="tooltip_view_error-title">{{{title}}}</div>
                <div class="tooltip_view_error-content">{{{error}}}</div>
                <a href="javascript:void(0)" class="tooltip_view-remove fa fa-times"></a>
            </div>
        """
        _error = $ _error_template title: title, error:error
        _error.css opacity: 0
              .appendTo 'body'
              .animate opacity: 1
              .find '.tooltip_view-remove'
              .on 'click', @errorClose

    @errorClose: -> _error.remove() if _error?


$ -> main.tooltip = tools.TooltipsView.getTooltip()


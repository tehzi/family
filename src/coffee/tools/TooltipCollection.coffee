class TooltipCollection extends Backbone.Collection
    localStorage: new Backbone.LocalStorage("bda2a6d8")

    constructor: (collection = [], options = {}) ->
        @model = TooltipModel
        super collection, options

    findByMark: (mark) ->
        @indexBy mark, 'mark'


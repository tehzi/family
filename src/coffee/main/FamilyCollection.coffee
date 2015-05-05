class FamilyCollection extends Backbone.Collection
    localStorage: new Backbone.LocalStorage "Family"
    model: null

    constructor: (args...) ->
        @model = FamilyModel
        super args...

    initialize: =>


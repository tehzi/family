class BookmarkCollection extends Backbone.Collection
    localStorage: new Backbone.LocalStorage("e39b168e")
    model: null

    constructor: (args...) ->
        @model = BookmarkModel
        super args...


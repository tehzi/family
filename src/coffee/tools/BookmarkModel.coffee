class BookmarkModel extends Backbone.Model
    defaults:
        icon:     null
        name:     null
        bookmark: null
        date:     new Date().getTime()
    idAttribute: 'bookmark'

    constructor: (args...) -> super args...


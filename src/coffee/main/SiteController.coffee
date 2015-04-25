class SiteController
    _instance = null

    view: null

    constructor: ->
        _.templateSettings =
            evaluate :   /\{\[([\s\S]+?)\]\}/g
            interpolate: /\{\{(.+?)\}\}/g
            escape:      /\{\{\{([\s\S]+?)\}\}\}/g
        @initialize()

    initialize: =>

    @getSiteController: => _instance = new SiteController if _instance is null

$ -> window.main = SiteController.getSiteController()


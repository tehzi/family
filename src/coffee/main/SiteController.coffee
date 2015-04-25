class SiteController
    _instance = null

    csstransitions: typeof Modernizr != 'undefined' && Modernizr.csstransitions
    view: null
    tooltip: null
    bookmark: null

    constructor: ->
        _.templateSettings =
            evaluate :   /\{\[([\s\S]+?)\]\}/g
            interpolate: /\{\{(.+?)\}\}/g
            escape:      /\{\{\{([\s\S]+?)\}\}\}/g
        @initialize()

    initialize: =>
        if !$('body').data('no_comic_view')
            @view = if @csstransitions then new PageViewTransitions parent: @ else new PageViewNoTransitions parent: @

    @getSiteController: => _instance = new SiteController if _instance is null

$ -> window.main = SiteController.getSiteController()


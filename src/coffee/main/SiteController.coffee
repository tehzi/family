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
        @controller()

    controller: =>
        if !$('body').data('no_comic_view')
            @view = if @csstransitions then new PageViewTransitions
            else                            new PageViewNoTransitions

    @getInstance: => _instance = new SiteController if _instance is null

$ -> window.main = SiteController.getInstance()


class SiteController
    _instance = null

    csstransitions: Modernizr && Modernizr.csstransitions
    view: null

    constructor: ->
        _.templateSettings =
            evaluate : /\{\[([\s\S]+?)\]\}/g
            interpolate: /\{\{(.+?)\}\}/g
        @controller()

    controller: =>
        @view = if @csstransitions then new PageViewTransitions
        else                            new PageViewNoTransitions

    @getInstance: =>
        _instance = new SiteController if _instance is null
        _instance

$ -> window.main = SiteController.getInstance()


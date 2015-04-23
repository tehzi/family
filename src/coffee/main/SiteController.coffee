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
            @view = if @csstransitions then new PageViewTransitions
            else                            new PageViewNoTransitions
        $('.dropdown-toggle').bind
            'show.bs.dropdown': (e) ->
                e.preventDefault()
                $(this).siblings('.dropdown-menu').first().stop(yes, yes)#.slideDown()
            'hide.bs.dropdown': (e) ->
                e.preventDefault()
                $(this).find('.dropdown-menu').first().stop(yes, yes)#.slideUp()

    @getInstance: => _instance = new SiteController if _instance is null

$ -> window.main = SiteController.getInstance()


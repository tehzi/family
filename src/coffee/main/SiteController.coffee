class SiteController
    _instance = null

    view: null

    constructor: -> @initialize()

    initialize: =>
        _.templateSettings =
            evaluate :   /\{\[([\s\S]+?)\]\}/g
            interpolate: /\{\{(.+?)\}\}/g
            escape:      /\{\{\{([\s\S]+?)\}\}\}/g
        bootbox.addLocale "ru", "OK": "Применить", "CANCEL": "Отмена", "CONFIRM": "Подтвердить"
        bootbox.setDefaults "locale", "ru"

    @getSiteController: => _instance = new SiteController if _instance is null

$ -> window.main = SiteController.getSiteController()


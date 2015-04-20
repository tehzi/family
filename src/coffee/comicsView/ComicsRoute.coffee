class ComicsRoute extends Backbone.Router
    constructor: (@parent) -> super()

    routes:
        '': 'index'
        'strip/:page(/)': 'stripChange'

    stripChange: (page) => @parent.setSlide page

    index: => @parent.setSlide 1


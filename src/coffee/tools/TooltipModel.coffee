class TooltipModel extends Backbone.Model
    idAttribute: 'mark'
    defaults:
        mark: false
        title: ""
        tip: ""
        autoshow: yes

    constructor: (args...) -> super args...


window.tools = _.extend window.tools || {}, LoadingBox: null

class window.tools.LoadingBox
    selector: ''

    _template: null

    _image = null
    _alt = ""
    _loadingBox = null
    _temp = "<img src='{{src}}' alt=''>"

    constructor: (@selector) ->
        _loadingBox = $ @selector
        @_template = _.template _temp

    setImage: (src) =>
        if _loadingBox? and _loadingBox.length
            _image = $ @_template src: src
            _image.on 'load', =>
                $(@).trigger 'end'
                if _alt then @setAlt _alt
            _loadingBox.append _image
            $(@).trigger 'start'

    getImage: -> _image

    setAlt: (alt) => if _image is null then _alt = alt else _image.attr 'alt', alt

    reset: ->
        _image = null
        _alt = ""
        @_template = _.template _temp



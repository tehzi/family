class Top
    constructor: ->
        @controller()

    controller: ->
        $ -> $('[data-plugin="top"]').click => $("html, body").animate 'scrollTop':0

new Top



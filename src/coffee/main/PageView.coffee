class PageView extends Backbone.View
    _title_interval: 0
    _forse_stop: false
    _events:
        'mouseenter [data-type="comics-title"]': '_comics_title'
        'mouseout [data-type="comics-title"]': '_comics_title'

    el: 'body .main'

    initialize: => @parent.tooltip.show()

    events: =>
        events = {}
        for key, val of @
            events = _.extend events, val if key.match(/^_.*events.*$/)
        events

    _slideHide: ($slide) =>
        $title = $ '[data-type="comics-title"]'
        $.when $title.parents('a').animate 'opacity': 0, 50
         .then ->
            $(@).attr 'href', $slide.data 'href'
            $title.html $slide.data 'description'

    _slideShow: ($slide) =>
        $title = $ '[data-type="comics-title"]'
        $title.parent()
              .css 'visibility': 'visible'
        $.when $title.parents('a').animate 'opacity': 1, 50
         .then -> $title.html $slide.data 'description'

    _comics_title: (e) =>
        $title = $ e.currentTarget
        $carousel = $ '#carousel-comics'
        tick = =>
            $.when $title.animate 'text-indent': -($title.textWidth() - 80), 2000
             .then $title.animate 'text-indent': 0, 2000
        do => if e.type == 'mouseenter'
            $carousel.find '.fa-pause'
                     .removeClass 'fa-pause'
                     .addClass 'fa-play'
            if $title.textWidth() > 80
                tick()
                clearInterval @_title_interval
                @_title_interval = setInterval tick, 4200
        do => if e.type == 'mouseout'
            clearInterval this._title_interval
            if !@_forse_stop
                $carousel.find '.fa-play'
                         .removeClass 'fa-play'
                         .addClass 'fa-pause'
        [$title, $carousel]


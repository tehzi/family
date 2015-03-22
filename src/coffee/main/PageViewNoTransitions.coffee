class PageViewNoTransitions extends PageView
    _interval = 0
    _timer = 0
    _force_stop = no

    _events_:
        'click #carousel-comics .carousel-controls a.fa-backward': '_prev'
        'click #carousel-comics .carousel-controls a.fa-pause':    '_stop'
        'click #carousel-comics .carousel-controls a.fa-play':     '_start'
        'click #carousel-comics .carousel-controls a.fa-forward':  '_next'

    constructor: ->
        super()
        _interval = $ '#carousel-comics'
                     .data 'interval'
        $ '#carousel-comics'
         .carousel 'pause'
         .removeAttr 'data-ride'
         .find 'a.fa-backward, a.fa-forward'
         .removeAttr 'data-slide'
         .click (e) -> e.preventDefault()
         .end()
         .addClass 'jcarousel'
         .jcarousel 'wrap': 'circular'
         .on 'jcarousel:scroll',       @_slideHide
         .on 'jcarousel:animateend',   @_slideShow
        @_start()

    _start: (e) =>
        @_timer = setInterval =>
                $ '#carousel-comics'
                 .data 'jcarousel'
                 .scroll '+=1'
            , _interval
        do => if e and e.type == 'click'
            $play = $ e.currentTarget
            $play.removeClass 'fa-play'
                 .addClass 'fa-pause'
            _force_stop = no

    _stop: (e) =>
        clearInterval @_timer
        do => if e and e.type == 'click'
            $pause = $ e.currentTarget
            $pause.removeClass 'fa-pause'
                  .addClass 'fa-play'
            _force_stop = yes

    _next: (e) =>
        @_stop()
        $ '#carousel-comics'
         .data 'jcarousel'
         .scroll '+=1'
        @_start() if !_force_stop

    _prev: (e) =>
        @_stop()
        $ '#carousel-comics'
         .data 'jcarousel'
         .scroll '-=1'
        @_start() if !_force_stop

    _slideHide: (e) =>
        super $(e.currentTarget).jcarousel 'target'

    _slideShow: (e) =>
        super $(e.currentTarget).jcarousel 'target'

    _comics_title: (e) =>
        [$title, $carousel] = super(e)
        do => if e.type == 'mouseenter' then @_stop()
        do => if e.type == 'mouseout'   then @_start()



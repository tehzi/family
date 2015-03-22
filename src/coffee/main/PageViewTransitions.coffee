class PageViewTransitions extends PageView
    _events_:
        'slide.bs.carousel #carousel-comics': '_slideHide'
        'slid.bs.carousel #carousel-comics': '_slideShow'

    _slideHide: (e) =>
        super $ e.relatedTarget

    _slideShow: (e) =>
        super $ e.relatedTarget

    _comics_title: (e) =>
        [$title, $carousel] = super(e)
        do => if e.type == 'mouseenter' then $carousel.carousel 'pause'
        do => if e.type == 'mouseout'   then $carousel.carousel 'cycle'


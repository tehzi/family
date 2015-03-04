var main;

$(function(){
    var PageView = Backbone.View.extend({
        'el': 'body',
        'events': {
            'click #carousel-comics .fa-pause': '_sliderToggle',
            'click #carousel-comics .fa-play': '_sliderToggle',
            'slide.bs.carousel #carousel-comics': '_slideHide',
            'slid.bs.carousel #carousel-comics': '_slideShow',
            'mouseenter [data-type="comics-title"]': '_comics_title',
            'mouseout [data-type="comics-title"]': '_comics_title'
        },
        '_title_interval': 0,
        '_forse_stop': false,
        '_sliderToggle': function(e){
            this._forse_stop = $(e.currentTarget).hasClass('fa-pause');
            if(this._forse_stop) {
                $(e.currentTarget).removeClass('fa-pause')
                                  .addClass('fa-play')
                                  .data('slide', 'pause');
            } else {
                $(e.currentTarget).removeClass('fa-play')
                                  .addClass('fa-pause')
                                  .data('slide', 'cycle');
            }
        },
        '_slideHide': function(e){
            var $slide = $(e.relatedTarget);
            var $title = $('[data-type="comics-title"]');
            $.when($title.parents('a').animate({'opacity': 0}, 50))
             .then(function(){ $(this).attr('href', $slide.data('href'));
                               $title.html($slide.data('description')); });
        },
        '_slideShow': function(e){
            var $slide = $(e.relatedTarget);
            var $title = $('[data-type="comics-title"]');
            $title.parent().css({'visibility': 'visible'});
            $.when($title.parents('a').animate({'opacity': 1}, 50))
             .then(function(){ $title.html($slide.data('description')); });
        },
        '_comics_title': function(e){
            var $title = $(e.currentTarget);
            var $carousel = $('#carousel-comics');
            if(e.type == 'mouseenter') {
                if($title.textWidth() > 80) {
                    function tick(){
                        $.when($title.animate({'text-indent': -($title.textWidth() - 80)}, 2000))
                         .then($title.animate({'text-indent': 0}, 2000));
                    }
                    $carousel.find('.fa-pause')
                             .removeClass('fa-pause')
                             .addClass('fa-play')
                             .data('slide', 'pause')
                             .end()
                             .carousel('pause');
                    tick();
                    clearInterval(this._title_interval);
                    this._title_interval = setInterval(tick, 4200);
                }
                return;
            }
            if(e.type == 'mouseout') {
                clearInterval(this._title_interval);
                if(!this._forse_stop) {
                    $carousel.find('.fa-play')
                             .removeClass('fa-play')
                             .addClass('fa-pause')
                             .data('slide', 'cycle')
                             .end()
                             .carousel('cycle');
                }
                return;
            }
        }
    });

    main = new PageView();
});
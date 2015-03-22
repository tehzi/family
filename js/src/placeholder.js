(function ($) {
    $.fn.placeholder = function (options) {

        var defaults = {};
        options = $.extend(defaults, options);

        return this.each(function () {
            var that = $(this);
            var top = that.offset().top;
            var left = that.offset().left;
            $('<span class="placeholder"/>').click(function(e){ $(e.currentTarget).hide();
                                                                that.focus(); })
                                            .text(that.data('placeholder'))
                                            .css({position: 'absolute'})
                                            .insertAfter(that);
            that.focus(function () {
                that.next('span.placeholder').hide();
            });
            that.blur(function () {
                if (that.val() == '') {
                    that.next('span.placeholder').show();
                }
            });
        });
    };

    $(function(){
        $('[data-placeholder]').placeholder();
    });
})(jQuery);
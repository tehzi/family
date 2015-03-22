$.fn.textWidth = function(){
    var text = $(this).html();
    $(this).html('<span>' + text + '</span>');
    var width = $(this).find('span:first').width();
    $(this).html(text);
    return width;
};
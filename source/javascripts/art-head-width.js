function rem(input) {
  var remSize = parseFloat($("body").css("font-size"),10);
  return (remSize * input);
}

$(document).ready(function() {
  $('.art-head').each(function( index ) {
    compWidth = 0;
    $(this).children().each(function() {
      compWidth += $(this).width();
    });
    if ($(window).width() > 750) {
      $(this).parent().css('width', compWidth);
      gpWidth = $(this).parent().parent().width();
      halvsies = (gpWidth - compWidth) / 2;
      $(this).parent().siblings('.rule-col').each(function() {
        $(this).css('width', halvsies)
      });
    }
  });
});

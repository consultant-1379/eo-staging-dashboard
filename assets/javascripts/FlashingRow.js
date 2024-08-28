$(function() {
    var on = false;
    window.setInterval(function() {
        on = !on;
        if (on) {
            $('.running').addClass('running-blink')
        } else {
            $('.running-blink').removeClass('running-blink')
        }
    }, 2000);
});
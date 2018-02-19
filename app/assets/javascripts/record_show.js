$(function() {

    // convert steps to link buttons
    var $btns = $("#record-meta-steps-btns"),
        video = $("video")[0],
        steps = $btns.text().split(",");

    $btns.html("");

    for (var i = 0, len = steps.length; i < len; i++) {
        $btns.append("<a href='#'>" + steps[i] + "</a>" + (i + 1 < len ? " | " : ""));
    }

    // steps click
    $btns.on("click", "a", function(e) {
        e.preventDefault();

        video.pause();
        video.currentTime = $(this).text();
    });

});

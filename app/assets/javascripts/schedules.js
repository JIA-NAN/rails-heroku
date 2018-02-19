$(function() {

    // pill time slot heading
    var h4 = "Pill Time Slot ";

    // add terminated date
    $("button.terminated-at").on("click", function(e) {
        e.preventDefault();

        $(this).addClass("hidden");
        $(".row.terminated-at").removeClass("hidden");
    });

    // create new pill time fields
    $("#add-pill-time").on("click", function(e) {
        e.preventDefault();

        var $times = $("#pill-times").find(".pill-time"),
            $base  = $($times.get(0)),
            $clone = $base.clone(true);

        // clear fields
        $clone.find("h4").html(h4 + ($times.length + 1));
        $clone.find(".pill-time-all").val("");
        $clone.find(".pill-time-hours").val("0900");

        // create and append
        $clone.appendTo("#pill-times").hide().slideDown(function() {
            $(this).find(".pill-time-all").focus();
        });
    });

    // verify time is in range 0000 - 2359
    function isValidTime(time) {
        // must be all number and 3-4 chars
        if (!/^[0-9]{3,4}$/.test(time)) { return false; }
        // get hour and minute
        var offset = time.length === 3 ? 1 : 2,
            hour = parseInt(time.substr(0, offset), 10),
            minute = parseInt(time.substr(offset), 10);

        if (hour < 0 || hour > 23) {
            return false;
        }

        if (minute < 0 || minute > 59) {
            return false;
        }

        return true;
    }

    // update pill times together
    $(".pill-time-all").on("focusout", function(e) {
        var $this = $(this),
            $parent = $this.parents(".pill-time");

        if ($this.val().length === 0) {
            // do nothing
        } else if (isValidTime($this.val())) {
            $parent.find(".pill-time-hours").each(function(idx, item) {
                $(item).val($this.val());
            });
        } else {
            alert("Time should in range from 0000 to 2359");
            // reset to default
            $this.val("0900");
        }
    });

    // check on pill times input
    $(".pill-time-hours").on("focusout", function(e) {
        var $this = $(this);

        if (!isValidTime($this.val())) {
            alert("Time should in range from 0000 to 2359");
            // reset to default
            $this.val("0900");
        }
    });

    // remove pill time fields
    $(".remove-pill-time").on("click", function(e) {
        e.preventDefault();

        if ($(".pill-time").length <= 1) {
            alert("You must have at least one pill time slot!");
        } else {
            $(this).parents(".pill-time").slideUp(function() {
                $(this).remove();

                // update headings
                $("#pill-times").find(".pill-time").each(function(idx) {
                    $(this).find("h4").html(h4 + (idx + 1));
                });
            });
        }
    });

});

$(function() {

    var $el = $("#recording-steps"),
        $nextStep = $("#next-step-btn");

    // expose components
    window.recordSequence = {
        idx: 0,
        timings: [],
        started: false,
        init: function() {
            this.idx = 0;
            this.timings = [];
            this.started = false;

            $el.html(initStep());

            if ($el.parent().hasClass("hidden")) {
                $el.parent().removeClass("hidden").hide().slideDown();
            }

            toggleBtn($nextStep, false, "Next Step", true);
        },
        ready: function() {
            this.started = true;

            $el.html(step(this.idx++));
            toggleBtn($nextStep, true);
        },
        next: function() {
            this.timings.push(statusBar.getTime());

            if (this.completed()) {
                return $("#record-btn").click();
            }

            $el.html(step(this.idx++));
        },
        end: function() {
            this.started = false;

            $el.html(endStep());
            toggleBtn($nextStep, false, "Next Step", true);
        },
        completed: function() {
            return this.idx >= steps.length;
        },
        result: function() {
            return this.timings.join(",");
        }
    };

    // next step button
    $nextStep.on("click", function() {
        recordSequence.next();
    });

    // space key to next step
    $("html").on("keydown", function(e) {
        if (recordSequence.started) {
            e.preventDefault();

            // space: 32, enter: 13
            if (e.keyCode === 32 || e.keyCode === 13) {
                recordSequence.next();
            }
        }
    });

    function initStep() {
        return "Prepare pill and water. Stay closer to webcam. If ready, Press";
    }

    function endStep() {
        return "Record Completed! Please submit your record.";
    }

    function step(idx) {
        if (idx == steps.length - 1) {
            $nextStep.html("Finish Record");
        } else {
            $nextStep.html("Next Step");
        }

        return "<b>Step " + (idx + 1) + "/" + steps.length + "</b> " + steps[idx].name;
    }

});

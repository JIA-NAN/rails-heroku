//= require grading/jquery.grader

$(function() {

    var $records = $(".record"),
        $playAllBtn = $("#play-all-records"),
        $playStepBtn = $("#play-step-records"),
        $jumpStepBtn = $playStepBtn.find(".play-step-list"),
        $saveBtn = $("#save-record-gradings"),

        // record videos status
        video_playing = false,
        video_num = $records.length,
        video_ended = 0,
        video_stopped = 0,

        // steps
        stepList = {
            $el: $("#record-sequence-steps"),
            $title: $playStepBtn,
            length: 0,
            currentStep: 0,
            init: function() {
                var self = this;

                this.length = this.$el.data("steps-num");
                this.currentStep = 0;

                this.$el.on("click", "a", function(e) {
                    e.preventDefault();

                    self.currentStep = $(this).data("step-num") - 1;
                    self.update();

                    $records.trigger("go_to_step", self.currentStep);
                });
            },
            next: function() {
                this.currentStep = (this.currentStep + 1) % this.length;
            },
            finished: function() {
                return this.currentStep + 1 >= this.length;
            },
            update: function() {
                // readable step number
                var stepNum = this.currentStep + 1;
                // update title
                this.$title.html(this.$title.html().replace(/\d+\/(\d+)/, stepNum + "/$1"));
                // update list current step
                this.$el.find("li").removeClass("current-step");
                this.$el.find("li:nth-child(" + stepNum + ")").addClass("current-step");
            }
        };

    stepList.init();

    // play to the end
    $playAllBtn.on("click", function(e) {
        e.preventDefault();

        // reset video count
        video_ended = 0;
        video_stopped = 0;

        if (video_playing) {
            $records.trigger("stop_video", { silent: true });
        } else {
            $records.trigger("play_video", { playAll: true });
        }

        video_playing = !video_playing;

        $playAllBtn.text(video_playing ? "Stop All" : "Play All");
        $playStepBtn.attr("disabled", video_playing);
    });

    // play step by step
    $playStepBtn.on("click", function(e) {
        e.preventDefault();

        // check if clicking on the dropdown
        if (e.target.className === "play-step-list") {
            return ;
        }

        // reset video count
        video_ended = 0;
        video_stopped = 0;

        if (video_playing) {
            $records.trigger("stop_video", { silent: true });
        } else {
            $records.trigger("play_video_until_step", stepList.currentStep);
        }

        video_playing = !video_playing;

        $playAllBtn.text(video_playing ? "Stop All" : "Play All");
        $playStepBtn.attr("disabled", video_playing);
    });

    // records grader plugin init
    $records.grader();

    $records.on("stopped", function() {
        video_stopped++;

        if (video_stopped + video_ended >= video_num) {
            video_stopped_playing();
        }
    });

    $records.on("ended", function() {
        video_ended++;

        if (video_stopped + video_ended >= video_num) {
            video_stopped_playing();
        }
    });

    function video_stopped_playing() {
        stepList.next();
        stepList.update();

        video_playing = false;

        $playAllBtn.text("Play All");
        $playStepBtn.attr("disabled", false);
    }

    // save records
    $saveBtn.on("click", function(e) {
        e.preventDefault();

        if ($saveBtn.attr("disabled")) { return ; }

        $records.trigger("save");
        $saveBtn.attr("disabled", true);
    });

});

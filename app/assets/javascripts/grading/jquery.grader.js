$(function() {

    function Grader(element, options) {
        this.$el = $(element);
        this.video = this.$el.find("video")[0];
        this.id = this.$el.data("id");
        this.steps = this.$el.data("meta").split(",").map(parseFloat);
        // this.grade = this.$el.data("grade"); // if it appears on this page, it must be ungraded?
        this.pill_taken = "nil"; // default to nil
		this.duration = this.video.duration;
        this.to_time = -1; // video default play from start to end

        // attach events
        this.$el.on("click", ".record-grade-tasks a", this.toggleTask.bind(this));
        this.$el.on("change", ".record-pill-taken", this.changePillTaken.bind(this));
        this.$el.on("save", this.save.bind(this));
        this.$el.on("play_video", this.play.bind(this));
        this.$el.on("stop_video", this.stop.bind(this));
        this.$el.on("go_to_step", this.go_to_step.bind(this));
        this.$el.on("play_video_until_step", this.play_until_step.bind(this));
        this.$el.on("mouseenter mouseleave", "video", this.toggleSound.bind(this));

        // debug mode
        if (window.debugMode) {
            this.debug_mode();
        }

        // video on end
        this.video.addEventListener("ended", function() {
            this.$el.trigger("ended");
            this.video.onended = null;
        }.bind(this));

        // video timeupdate
        this.video.addEventListener("timeupdate", function() {
            if (this.to_time >= 0 && this.video.currentTime >= this.to_time) {
                this.to_time = -1;
                this.stop();
            }
        }.bind(this));
    }

    Grader.prototype = {
        debug_mode: function() {
            this.video.controls = true;
            this.$el.find(".record-grade-info").append("<p>" + this.steps.join(",") + "</p>");
        },
        toggleTask: function(e) {
            e.preventDefault();

            var $this = $(e.target),
                task  = $this.data("task");

            this.$el.find("li").removeClass("active");
            this.$el.find(".record-task-panel").addClass("hidden");
            this.$el.find(".record-grade-" + task).removeClass("hidden");

            $this.parent().addClass("active");
        },
        changePillTaken: function(e) {
            var new_value = e.target.value;
            this.pill_taken = new_value;
            this.$el.removeClass("pill-taken-yes pill-taken-no pill-taken-not-sure")
                    .addClass("pill-taken-" + new_value.replace(/\s/, "-"));
        },
        // play video
        play: function(e, options) {
            if (options && options.playAll) {
                this.to_time = -1;
            }

            this.video.muted = true;
            this.video.play();
        },
        // stop video
        stop: function(e, options) {
            this.video.pause();

            if (!options || !options.silent) {
                this.$el.trigger("stopped");
            }
        },
        // go the end of step idx (starting from 0)
        go_to_step: function(e, idx) {
            this.video.currentTime = this.get_time(idx) - 0.5;

            if (this.video.currentTime < 0) {
                this.video.currentTime = 0;
            }
        },
        // play from previous step to step idx (starting from 0)
        play_until_step: function(e, idx) {
            this.to_time = this.get_time(idx);
            this.go_to_step(null, idx - 1);

            this.play();
        },
        get_time: function(idx) {
            if (idx < 0) {
                return 0;
            } else if (idx >= this.steps) {
                return this.duration;
            } else {
                return this.steps[idx];
            }
        },
        toggleSound: function() {
            this.video.muted = !this.video.muted;
            this.video.controls = !this.video.controls;
        },
        save: function() {
            var self = this,
                note = self.$el.find(".record-note"),
                comment = self.$el.find(".record-feedback");
			if (self.pill_taken != "nil") {
		        $.post("/records/" + this.id + "/grades.json", {
		            "grade[record_id]": self.id,
		            "grade[pill_taken]": self.pill_taken,
		            "grade[note]": note.val(),
		            "grade[comment]": comment.val(),
				}).done(function(res) {
			    	self.$el.find("select").after("<p>" + self.pill_taken + "</p>").remove();
                	note.after("<p>" + note.val() + "</p>").remove();
                	comment.after("<p>" + comment.val() + "</p>").remove();
				});
        	}
		}
    };

    $.fn.grader = function (options) {
        return this.each(function() {
            if ( !$.data(this, "plugin_grader") ) {
                $.data(this, "plugin_grader", new Grader(this, options));
            }
        });
    };

});

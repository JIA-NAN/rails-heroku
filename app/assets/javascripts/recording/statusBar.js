$(function() {

    // statusBar of the recorder
    window.statusBar = {
        $el: $("#recorder-status"),
        // timer interval
        interval: null,
        // time numbers
        min:    0,    // minute
        sec:    0,    // second
        start:  null, // start time
        offset: 0,    // time offset
        // internal: format time display
        fmt: function(t) {
            return (t > 9 ? "" : "0") + t;
        },
        // internal: change el class
        state: function(state) {
            return this.$el.removeClass().addClass(state);
        },
        // idle state
        idle: function() {
            this.state("idle").html("STOPPED");
        },
        // starting recorder transition state
        preparing: function() {
            this.state("idle").html("RECORD STARTING...");
        },
        // on recording state
        recording: function() {
            this.start = new Date();
            this.state("recording").html("REC 00:00");

            // clear interval
            if (this.interval) {
                clearInterval(this.interval);
            }

            // update status timing at 1s rate
            this.interval = setInterval(function() {
                // get total seconds elapsed
                var sec = (new Date() - this.start) / 1000 | 0;

                this.min = sec / 60 | 0;
                this.sec = sec - 60 * this.min;

                this.$el.html("REC " + this.fmt(this.min) +
                             ":"    + this.fmt(this.sec));
            }.bind(this), 1000);
        },
        // get the time at recording frame
        getTime: function() {
            return (new Date() - this.start + this.offset) / 1000;
        },
        // set the time offset
        setTimeOffset: function(offset) {
            this.offset = offset;
        },
        // stop recording state
        stopping: function() {
            if (this.interval) {
                clearInterval(this.interval);
            }

            this.state("stop").html("RECORD STOPPING...");
        },
        // recording stopped
        stopped: function() {
            if (this.interval) {
                clearInterval(this.interval);
            }

            this.state("stop")
                .html("STOPPED [" + this.fmt(this.min) + ":" +
                      this.fmt(this.sec) + "]");
        }
    };

});

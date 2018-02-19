$(function() {

    // Public: Generate Recorder Options
    window.recorderOptions = function () {
        var v_width = $("#recorder").innerWidth(), v_height,
            c_width = 480, c_height = 320;

        if (v_width >= 640) {
            v_width = 640;
            v_height = 480;
        } else if (v_width >= 480) {
            v_width = 480;
            v_height = 360;
        } else  {
            v_width = 320;
            v_height = 240;
            c_width = 320;
            c_height = 240;
        }
        // resize container
        $("#recorder-container").css({ "width": v_width + 30 });

        return {
            enable: { video: true, audio: true },
            video_width: v_width,
            video_height: v_height,
            canvas_width: c_width,
            canvas_height: c_height,
            videoElem: document.getElementById("client-video")
        };
    };

    // Public: browser requirements check
    window.browserCheckValid = function() {
        if (RecordRTC.support.video && RecordRTC.support.audio &&
            RecordRTC.support.webp()) {
            $("#compatible-alert").remove();

            return true;
        } else {
            $("#recorder").html("<p>Error! Your browser only support: <ul>" +
                    "<li>Video/WebP: " + RecordRTC.support.webp() + "</li>" +
                    "<li>Video/Record: " + RecordRTC.support.video + "</li>" +
                    "<li>Audio/Record: " + RecordRTC.support.audio + "</li>" +
                    "</ul></p>").css("padding-left", "50px");

            return false;
        }
    };

    // Public: Perform AJAX operation
    //
    // data - form data
    // url - form submit url
    // type - form submit type (POST, PUT)
    // ajaxHandler - ajax result handler
    // progressHandler - ajax progress handler
    window.doAJAX = function(data, url, type, ajaxHandler, progressHandler) {
        var oReq = new XMLHttpRequest();

        oReq.overrideMimeType("multipart/form-data; charset=x-user-defined");
        oReq.open(type, url);
        if (progressHandler) { oReq.upload.onprogress = progressHandler; }
        if (ajaxHandler) { oReq.onload = ajaxHandler; }
        oReq.send(data);

        return oReq;
    };

    // Public: Toggle Button State and Content
    //
    // btn - jQuery DOM object
    // state - disabled state (true = enable)
    // text - btn content
    window.toggleBtn = function(btn, state, text, hide) {
        btn.prop("disabled", !state);
        // make it visible
        if (state) { btn.removeClass("hidden").hide().fadeIn(); }
        // change text
        if (text) { btn.html(text); }
        // if hide
        if (hide) { btn.addClass("hidden"); }
    };

    // Public: Countdown from count to 0
    //
    // count - number of counts
    //
    // Returns a Deferred object
    window.countdown = function(count, el) {
        var dtd = $.Deferred(),
            $el = el || $("#recorder-count"),
            countStart = null,
            counter = function() {
                if (count === 0) {
                    $el.addClass("hidden");
                    dtd.resolve(new Date() - countStart);
                } else {
                    $el.html(count);
                    setTimeout(counter, 1000);
                }

                count = count - 1;
            };

        $el.removeClass("hidden");

        counter(); // start counting down
        countStart = new Date(); // record count time

        return dtd.promise();
    };

    // Public: A single state monitor
    //
    // Example:
    //
    // state = new StateMonitor();
    // state.trigger(object);
    // state.listen(function)
    //
    // Returns a StateMonitor object
    window.StateMonitor = function() {
        var dtd = $.Deferred();

        this.trigger = function(result) {
            dtd.resolve(result);
        };

        this.listen = function(fn) {
            dtd.done(fn);
        };
    };
});

$(function() {

    var unloadListener = function(e) {
        var confirmationMessage = "Video is still uploading. " +
                                  "Please wait patiently before closing the window.";

        (e || window.event).returnValue = confirmationMessage;     //Gecko + IE
        return confirmationMessage;                                //Webkit, Safari, Chrome etc.
    };

    window.recordData = {
        // file blobs
        videoBlob: null,
        audioBlob: null,

        // submit record data
        submit: function() {
            // wait half a second if blob is not ready
            if (!this.videoBlob || !this.audioBlob) {
                return setTimeout(this.submit.bind(this), 500);
            }

            // register unload event
            window.addEventListener("beforeunload", unloadListener);

            // set up additional data
            var $recorder = $("#recorder"),
                data = new FormData(),
                filename = (new Date()).getTime(),
                url  = $("#new_record").attr("action") + ".json",
                type = "POST",
                ajaxHandler = function(req) {
                    if (req.target.status == 201) {
                        feedbackModal.ready(JSON.parse(req.target.response));
                    } else {
                        feedbackModal.error("submitting record");
                    }

                    // unregister unload event
                    window.removeEventListener("beforeunload", unloadListener);
                },
                progressHandler = function(e) {
                    if (e.lengthComputable) {
                        var uploadPercentage = (e.loaded / e.total) * 100 | 0;
                        console.log(uploadPercentage);
                    }
                };

            // append data
            data.append("record[device]", navigator.platform);
            data.append("record[pill_sequence_id]", $recorder.data("sequence"));
            data.append("record[pill_time_at]", $recorder.data("pill-time"));
            data.append("record[meta]", recordSequence.result());
            data.append("record[video]", this.videoBlob, filename + ".webm");
            data.append("record[audio]", this.audioBlob, filename + ".wav");

            // perform ajax post
            doAJAX(data, url, type, ajaxHandler, progressHandler);
        }
    };

});

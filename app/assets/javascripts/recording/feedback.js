$(function() {

    var $closeModalBtn = $("#close-modal-btn");

    window.feedbackModal = {
        el: $("#record-modal"),
        // record submitted data
        recordReady: new StateMonitor(),
        // feedback messages
        msg: {
            succeed: "Your record is submitted.",
            failed: "Error happened when "
        },
        // open modal
        open: function() {
            this.el.foundation("reveal", {
                closeOnBackgroundClick: false,
                closeOnEsc: false
            });

            this.el.foundation("reveal", "open");
        },
        // close modal
        close: function() {
            this.el.foundation("reveal", "close");
        },
        // internal: can close the modal
        closeOnClick: function(text) {
            this.el.foundation("reveal", {
                closeOnBackgroundClick: true,
                closeOnEsc: true
            });

            this.el.append("<a class='close-reveal-modal'>&#215;</a>");

            // display succeed message
            this.el.find("#record-modal-title").html(text);

            toggleBtn($closeModalBtn, true);
        },
        // ready state, record is submitted
        ready: function(record) {
            // put record to access
            this.recordReady.trigger(record);

            // redirect to records page after modal close
            this.el.on("close", function() {
                feedbackModal.recordReady.listen(submitFeedback);
            });

            this.closeOnClick("<h3 class='succeed'>" + this.msg.succeed + "</h3>");
        },
        // error state
        error: function(text) {
            this.closeOnClick("<h3 class='failed'>" + this.msg.failed + text + ".</h3>");
        }
    };

    $closeModalBtn.on("click", function() {
        feedbackModal.close();
    });

    function submitFeedback(record) {
        var arr = $("#new_record").serializeArray(),
            data = new FormData(),
            url = "/patients/" + record.patient_id +
                  "/records/" + record.id + ".json",
            type = "PUT",
            ajaxHandler = function(req) {
                if (req.target.status == 204) {
                    location.href = "/records";
                } else {
                    feedbackModal.error("saving feedbacks");
                }
            };

        // append data
        for (var i = 0; i < arr.length; i++) {
            data.append(arr[i].name, arr[i].value);
        }

        // perform ajax post
        doAJAX(data, url, type, ajaxHandler);
    }

});

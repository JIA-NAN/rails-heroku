//= require recording/utils
//= require recording/RecordRTC-together
//= require recording/painter
//= require recording/headtrackr
//= require recording/headtracking
//= require recording/lighting
//= require recording/prechecker
//= require recording/recordData
//= require recording/statusBar
//= require recording/sequence
//= require recording/feedback

$(function() {

    var recorder = null,
        isRecording = false,
        // buttons
        $recordBtn = $("#record-btn"),
        $submitBtn = $("#submit-btn");

    // browser requirements check
    setTimeout(function() {
        if (browserCheckValid()) {
            initRecorder();
        }
    }, 100);

    // on getUserMedia succeed
    function onMediaSuccess(m) {
        // display video
        recorder.setMedia(m);
        // precheckings
        prechecker.init();
        // display instructions
        recordSequence.init();
        // init status bar
        statusBar.idle();
        // display video face boxes
        // we hide the face boxes when the video frame is too small
        if(recorder.v_width >320)
            $("#recorder-face-zone").removeClass("hidden");
    }

    // on getUserMedia failed
    function onMediaError() {
        $("#recorder").html(
            "<div class='large-12 columns'><p>" +
            "Please refresh the browser and allow access to your webcam and microphone." +
            "</p></div>");
    }

    // init recorder for recording
    function initRecorder() {
        recorder = new RecordRTC(recorderOptions());

        // get user media
        recorder.getMedia(onMediaSuccess, onMediaError);

        // listen and handle recorder results
        recorder.onVideoReady(function(blob) { recordData.videoBlob = blob; });
        recorder.onAudioReady(function(blob) { recordData.audioBlob = blob; });
    }

    // start/stop recording button
    $recordBtn.on("click", function() {
        var succeed = true;

        if (isRecording) {
            succeed = stopRecorder();
        } else {
            succeed = startRecorder();
        }

        if (succeed) {
            isRecording = !isRecording;
        }
    });

    function startRecorder() {
        recorder.start();

        toggleBtn($recordBtn, false);
        toggleBtn($submitBtn, false);

        statusBar.preparing();

        // display countdown to delay 3s
        countdown(3).done(function(spent) {
            toggleBtn($recordBtn, true, "<i class='fi-stop'></i>");

            statusBar.setTimeOffset(spent);
            statusBar.recording();

            recordSequence.ready();
        });

        return true;
    }

    function stopRecorder() {
        if (!recordSequence.completed()) {
            if (!confirm("You did not complete all steps! " +
                         "Stop recording means you need to record again. " +
                         "Are you sure?")) {
                return false;
            }
        }

        toggleBtn($recordBtn, false);

        statusBar.stopping();

        // delay about 2s before actual stop
        setTimeout(function() {
            recorder.stop();

            statusBar.stopped();

            if (recordSequence.completed()) {
                // sequence completed
                recordSequence.end();
                // stop webcam access
                recorder.stream.stop();

                toggleBtn($recordBtn, false, null, true);
                toggleBtn($submitBtn, true);
            } else {
                recordSequence.init();

                toggleBtn($recordBtn, true, "Record Again");
            }
        }, 2000);

        return true;
    }

    // submit record
    $submitBtn.on("click", function() {
        feedbackModal.open();
        // wait half a second for video blobs get ready
        setTimeout(recordData.submit.bind(recordData), 500);
    });

});

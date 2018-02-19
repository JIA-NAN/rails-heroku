$(function() {

    var startTime = null,
        $message = $("#recorder-message"),
        $recordBtn = $("#record-btn");

    // one time event handler
    function bindRecordStart() {
        $recordBtn.one("click", function() {
            lighting.options.handler = null;
            lighting.stop();

            facetracking.options.handler = faceHandler;

            $("#next-step-btn").one("click", function() {
                facetracking.options.handler = null;
            });

            $recordBtn.one("click", function() { // retake
                facetracking.options.handler = null;
                $message.addClass("hidden").removeClass("anim-blink");
                bindRecordStart();
            });
        });
    }

    function lightingHandler(lighting) {
        if (lighting.isStablized()) {
            if (lighting.isOk()) {
                if (!$message.hasClass("hidden")) {
                    $message.addClass("hidden").removeClass("anim-blink");
                }

                if ($recordBtn.prop("disabled")) {
                    $recordBtn.prop("disabled", false);
                }

                if (!startTime) {
                    startTime = new Date();
                } else if (new Date() - startTime > 5000) { // delay 5s before actual stop checking
                    lighting.stop();
                }
            } else {
                startTime = null;

                if ($message.hasClass("hidden")) {
                    $message.html("Face area is dark, please adjust lighting.");
                    $message.removeClass("hidden").addClass("anim-blink");
                }

                if (!$recordBtn.prop("disabled")) {
                    $recordBtn.prop("disabled", true);
                }
            }
        }
    }

    function faceHandler(event) {
        var xcentre = 0, ycentre = 0, zcentre = 0;

        // horizontal center range: 160~40
        if (event.x < 120) { // close to right
            xcentre = 1;
        } else if (event.x > 200) { // close to left
            xcentre = -1;
        }

        // vertical center range: 120~20
        if (event.y < 100) { // close to top
            ycentre = 1;
        } else if (event.y > 140) { // close to bottom
            ycentre = -1;
        }

        // width and height
        if (event.width < 60 || event.height < 60) {
            zcentre = -1;
        }

        if (xcentre !== 0 || ycentre !== 0 || zcentre !== 0) {
            if ($message.hasClass("hidden")) {
                $message.html("Please position your head in the white box.");
                $message.removeClass("hidden").addClass("anim-blink");
            }
        } else {
            if (!$message.hasClass("hidden")) {
                $message.addClass("hidden").removeClass("anim-blink");
            }
        }

        if (window.debugMode) {
            $("#debug-headjudged").html("[X:" + xcentre +
                                        ",Y:" + ycentre +
                                        ",Z:" + zcentre + "]");
        }
    }

    window.prechecker = {

        init: function() {
            var canvas = document.getElementById("client-painter");
            // start painting
            painter.start(document.getElementById("client-video"), canvas);
            // start face tracking
            facetracking.start(canvas, {
                overlayCanvas: document.getElementById("client-overlay")
            });
            // start lighting checking
            lighting.start(canvas, { handler: lightingHandler });
            // bind record start
            bindRecordStart();
        }

    };

});

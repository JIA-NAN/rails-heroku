$(function() {

    // add some custom messaging
    var statusMessages = {
        "whitebalance" : "checking for stability of camera whitebalance",
        "detecting" : "Detecting face",
        "hints" : "Detecting the face is taking a long time",
        "redetecting" : "Lost track of face, redetecting",
        "lost" : "Lost track of face",
        "found" : "Tracking face"
    };

    window.facetracking = {
        htracker: null,
        found: false,

        debugContext: null,
        overlayContext: null,

        options: {
            handler: null,
            debugCanvas: null,
            overlayCanvas: null
        },

        start: function(canvasElem, options) {
            this.options = $.extend({}, this.options, options);

            // for debugging purpose
            if (this.options.overlayCanvas) {
                this.overlayContext = this.options.overlayCanvas.getContext("2d");

                this.options.overlayCanvas.style.position = "absolute";
                this.options.overlayCanvas.style.top = "0px";
                this.options.overlayCanvas.style.zIndex = "100001";
                this.options.overlayCanvas.style.display = "block";
            }

            this.htracker = new headtrackr.Tracker({
                calcAngles: false,
                headPosition: false,
                detectionInterval: 100,
                smoothingInterval: 115
            });

            this.htracker.init(canvasElem);
            this.htracker.start();

            // face tracking
            document.addEventListener("facetrackingEvent",
                                      this.onFaceUpdate.bind(this), true);
            // tracker status
            if (window.debugMode) {
                document.addEventListener("headtrackrStatus",
                                        this.onStatus.bind(this), true);
            }
        },

        onStatus: function(event) {
            if (event.status in statusMessages) {
                $("#debug-trackerstatus").html(statusMessages[event.status]);
            }
        },

        // for each facetracking event received
        // draw rectangle around tracked face on canvas
        onFaceUpdate: function(event) {
            if (event.detection == "CS") {
                if (this.options.handler) {
                    this.options.handler(event);
                }

                if (window.debugMode) {
                    $("#debug-headtracking").html("[W:" + event.width +
                                                  ",H:" + event.height +
                                                  ",X:" + event.x +
                                                  ",Y:" + event.y + "]");

                    // once we have stable tracking, draw rectangle
                    if (this.overlayContext) {
                        this.drawOverlay(event);
                    }
                }
            }
        },

        drawOverlay: function(event) {
            this.overlayContext.clearRect(0,0,640,480);

            this.overlayContext.translate(event.x, event.y);
            this.overlayContext.rotate(event.angle - (Math.PI/2));
            this.overlayContext.strokeStyle = "#00CC00";
            this.overlayContext.strokeRect((-(event.width/2)) >> 0, (-(event.height/2)) >> 0, event.width, event.height);
            this.overlayContext.rotate((Math.PI/2)-event.angle);
            this.overlayContext.translate(-event.x, -event.y);
        },

        stop: function() {
            // clear event listeners
            document.removeEventListener("facetrackingEvent",
                                         this.onFaceUpdate.bind(this), true);
            if (window.debugMode) {
                document.removeEventListener("headtrackrStatus",
                                             this.onStatus.bind(this), true);
            }
            // stop tracking
            this.htracker.stop();
        }
    };

});

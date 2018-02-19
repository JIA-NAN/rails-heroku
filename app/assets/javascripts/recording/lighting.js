$(function() {

    // lighting threshold
    var DARK_THRESHOLD = 20,
        LOW_LIGHT_THRESHOLD = 40,
    // maximum history collection
        MAX_HISTORY_NUM = 10,
    // browser compatibility
        requestAnimationFrame = window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame,
        cancelAnimationFrame = window.webkitCancelAnimationFrame || window.mozCancelAnimationFrame;

    window.lighting = {
        history: [],

        canvas: null,
        lastAnimationFrame: null,
        startTime: null,
        stablizedLuma: null,

        condition: 'normal', // normal, dark, low light
        state: 'S', // S (stablizing), V (verifying), Y (ready)

        options: {
            autoStop: false, // when state reached Y
            handler: null // handle state
        },

        // start checking lighting condition
        start: function(canvas, options) {
            this.canvas = canvas;
            this.startTime = new Date();
            this.options = $.extend({}, this.options, options);
            this.lastAnimationFrame = requestAnimationFrame(this.track.bind(this));
        },

        // tracking conditions
        track: function(time) {
            // ~10 fps
            if (time - this.lastFrameTime < 90) return ;

            if (this.state == 'Y') {
                if (this.options.autoStop) {
                    this.stop();
                } else {
                    this.checkLighting();
                    this.lastAnimationFrame = requestAnimationFrame(this.track.bind(this));
                }
            } else {
                if (this.state == 'S') {
                    this.checkStability();
                } else if (this.state == 'V') {
                    this.checkLighting();
                }

                this.lastAnimationFrame = requestAnimationFrame(this.track.bind(this));
            }

            if (this.options.handler && (new Date() - this.startTime) > 900) {
                this.options.handler(this);
            }

            if (window.debugMode && this.stablizedLuma) {
                $('#debug-lighting').html(this.stablizedLuma.toFixed(3) + ',' +
                                          this.state + ': ' + this.condition);
            }
        },

        // check stability
        checkStability: function() {
            if (this.history.length >= MAX_HISTORY_NUM) {
                this.history.pop();
            }

            this.history.unshift(getLuma(this.canvas));

            if (this.history.length == MAX_HISTORY_NUM) {
                // get max
                var max = Math.max.apply(null, this.history);
                // get min
                var min = Math.min.apply(null, this.history);

                // if difference between the last ten luma is less than 2,
                // we assume the camera lighting is stable
                if ((max - min) < 2) {
                    this.stablizedLuma = (max + min) / 2;
                    this.state = 'V'; // start verifying
                }
            }
        },

        // verifying lighting condition
        checkLighting: function() {
            var luma = getLuma(this.canvas);

            if (luma - this.stablizedLuma > 9 || luma - this.stablizedLuma < -9) {
                // if the difference changed dramatically,
                // we assume the lighting condition has changed, re-stablizing
                this.history = [];
                this.state = 'S';
            } else {
                if (luma <= DARK_THRESHOLD) {
                    this.condition = 'dark';
                    this.state = 'V';
                } else if (luma <= LOW_LIGHT_THRESHOLD) {
                    this.condition = 'low light';
                    this.state = 'V';
                } else {
                    this.condition = 'normal';
                    this.state = 'Y';
                }
            }

            this.stablizedLuma = luma;
        },

        // stop checking
        stop: function() {
            if (this.lastAnimationFrame) {
                cancelAnimationFrame(this.lastAnimationFrame);
            }
        },

        // return true if lighting condition is good
        isOk: function() {
            return this.state == 'Y';
        },

        // return true if lighting condition is stablized
        isStablized: function() {
            return this.state != 'S';
        }
    };

    // calculate the average weighted sRGB Luma value
    // in centre/face part of the canvas (by rows, span)
    function getLuma(canvas, rows, span) {
        rows = rows || 10; // divide the canvas in 10 eql rows (default)
        span = span || 2;  // only consider the centre 2 rows (default)

        var canvasContext = canvas.getContext('2d'),
            image = canvasContext.getImageData(0, 0, canvas.width, canvas.height),
            id = image.data,
            width = canvas.width,
            height = canvas.height,
            rowWidth = width / rows | 0,
            rowStartIdx = (rows - span) / 2 | 0,
            rowStart = rowWidth * rowStartIdx,
            rowEnd = rowWidth * (rowStartIdx + span),
            imagesize = height * rowWidth * span,
            luma = 0;

        // iterate only the specified (x, y) part
        for (var y = 0; y < height; y++) {
            for (var x = rowStart; x < rowEnd; x++) {
                var pos = ((width * y) + x) * 4;

                luma += id[pos] * 0.2126 +
                        id[pos + 1] * 0.7152 +
                        id[pos + 2] * 0.0722;
            }
        }

        return luma / imagesize;
    }

});

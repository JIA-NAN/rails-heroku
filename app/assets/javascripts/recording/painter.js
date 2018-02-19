$(function() {

    var requestAnimationFrame = window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame,
        cancelAnimationFrame = window.webkitCancelAnimationFrame || window.mozCancelAnimationFrame;

    window.painter = {
        lastVideoFrame: null,
        lastFrameTime: null,

        video: null,
        canvas: null,
        context: null,
        options: {},

        // opts: { canvasWidth: 320, canvasHeight: 240 }
        start: function(videoElem, canvasElem, opts) {
            // video elem
            this.video = videoElem;
            // canvas
            this.canvas = canvasElem;
            this.context = this.canvas.getContext('2d');
            // init canvas width/canvas
            this.options = opts || {};
            this.canvas.width = this.options.canvasWidth || 320;
            this.canvas.height = this.options.canvasHeight || 240;
            // start painting
            this.lastVideoFrame = requestAnimationFrame(this.paint.bind(this));
        },

        paint: function(time) {
            this.lastVideoFrame = requestAnimationFrame(this.paint.bind(this));

            if (!this.lastFrameTime) {
                this.lastFrameTime = time;
            }

            // ~10 fps
            if (time - this.lastFrameTime < 90) return ;

            this.context.drawImage(this.video, 0, 0,
                                   this.canvas.width, this.canvas.height);

            this.lastFrameTime = time;
        },

        stop: function() {
            if (this.lastVideoFrame) {
                cancelAnimationFrame(this.lastVideoFrame);
            }
        }
    };

});

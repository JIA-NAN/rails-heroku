$(function() {

    var $el    = $("#pill-sequence-steps"),
        $steps = function() {
            return $el.find(".new-pill-sequence-step");
        },
        $base  = $($steps().get(0));

    // add a sequence step to the bottom
    $("#add-pill-sequence-step").on("click", function(e) {
        e.preventDefault();

        var $clone = $base.clone(true);

        setStepOrder($clone, $steps().length + 1);
        $clone.find(".new-pill-sequence-step-name").val("");

        $clone.appendTo($el).hide().slideDown(function() {
            $(this).find(".new-pill-sequence-step-name").focus();
        });
    });

    // event on each step
    $el.on("click", ".new-pill-sequence-step", function(e) {
        e.preventDefault();

        var action = $(e.target),
            steps  = $steps(),
            step   = $(this),
            idx    = step.index() + 1;

        if (action.hasClass("move-up")) {
            if (idx === 1) { return ; }

            step.prev().before(step.detach());

            clearStepOrders();
        } else if (action.hasClass("move-down")) {
            if (idx === steps.length) { return ; }

            step.next().after(step.detach());

            clearStepOrders();
        } else if (action.hasClass("remove")) {
            if (steps.length === 1) {
                alert("You cannot remove the last step.");
                return ;
            }

            step.off().slideUp(function() {
                $(this).remove();

                clearStepOrders();
            });
        }
    });

    // make clear all steps' order
    function clearStepOrders() {
        var steps = $steps();

        $steps().each(function(idx) {
            setStepOrder($(this), idx + 1);
        });
    }

    // set index of a step
    function setStepOrder($elem, idx) {
        $elem.find(".prefix").html("Step " + idx);
        $elem.find(".new-pill-sequence-step-order").val(idx);
    }

});

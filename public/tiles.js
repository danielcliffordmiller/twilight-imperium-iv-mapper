
"use strict";

$(document).ready(function() {
    $(".hand").click(function(event) {
	$(".selected").removeClass("selected");
	$("."+this.id).addClass("selected");
	$(this).addClass("selected");
    });
    $(".map").click(function(event) {
        if ($(this).hasClass("selected")) Intercooler.triggerRequest(this);
    });
    $(document).on("beforeAjaxSend.ic", function(event, ajaxSetup, elt) {
	ajaxSetup.data = ajaxSetup.data + "&hand=" + $(".hand.selected")[0].id;
    });
});


"use strict";

function handleReady() {
    $(".hand").click(function(event) {
	$(".selected").removeClass("selected");
	$("."+this.getAttribute("tile-type")).addClass("selected");
	$(this).addClass("selected");
    });
    $(".map").click(function(event) {
        const elt = this;
        if ($(this).hasClass("selected")) {
            $("#confirm").addClass("active");
            $('#c-yes').off("click");
            $("#c-yes").click(function(event){
                $("#confirm").removeClass("active");
                Intercooler.triggerRequest(elt);
            });
        }
    });
    $(document).on("beforeAjaxSend.ic", function(event, ajaxSetup, elt) {
	ajaxSetup.data = ajaxSetup.data + "&hand=" + $(".hand.selected")[0].id;
    });
    $("#c-no").click(function(event){
        $("#confirm").removeClass("active");
    });
    Intercooler.ready(function(elt){ handleReady() });
}
$(document).ready(handleReady);

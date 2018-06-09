
"use strict";

function handleHandClick() {
  $(".selected").removeClass("selected");
  $("."+this.getAttribute("tile-type")).addClass("selected");
  $(this).addClass("selected");
}
function handleMapClick() {
  const elt = this;
  if ($(this).hasClass("selected")) {
    $("#confirm").addClass("active");
    $('#c-yes').off("click");
    $("#c-yes").click(function(event){
	    $("#confirm").removeClass("active");
	    Intercooler.triggerRequest(elt);
    });
  }
}
function handleReady() {
  $(document).on("beforeAjaxSend.ic", function(event, ajaxSetup, elt) {
    ajaxSetup.data = ajaxSetup.data + "&hand=" + $(".hand.selected")[0].id;
  });
  $("#c-no").click(function(event){
    $("#confirm").removeClass("active");
  });
}
$(document).ready(handleReady);

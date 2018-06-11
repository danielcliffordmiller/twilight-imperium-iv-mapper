
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

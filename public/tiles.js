
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
function handleLogClick() {
  $('#map use[href="#log-outline"]').remove();
  $(".log-selection").removeClass('log-selection');

  const xmlns="http://www.w3.org/2000/svg";
  const g = document.createElementNS(xmlns, 'g');
  g.setAttribute("transform", "translate("+this.getAttribute('coords')+")");
  const use = document.createElementNS(xmlns, 'use');
  use.setAttribute('href', "#log-outline");
  g.appendChild(use);
  $("#map > svg").append(g);

  $(this).addClass('log-selection');
}

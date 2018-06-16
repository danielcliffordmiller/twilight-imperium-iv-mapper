
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
  //const elt = '<g transform="translate('+this.getAttribute('coords')+')"><path id="log-outline" d="M -25 -43 l 50 0 25 43 -25 43 -50 0 -25 -43 z" fill="black" fill-opacity="0.0" stroke-width="2" stroke-linejoin="round" stroke="black" /></g>';
  const xmlns="http://www.w3.org/2000/svg";
  const g = document.createElementNS(xmlns, 'g');
  g.setAttribute("transform", "translate("+this.getAttribute('coords')+")");
  const use = document.createElementNS(xmlns, 'use');
  use.setAttribute('href', "#log-outline");
  g.appendChild(use);
  $("#map > svg").append(g);
  //const logElt = this;
  //$("#map > svg").each( function(i) {
  //  const g = this.createElement('g');
  //  g.setAttribute("transform", "translate("+logElt.getAttribute('coords')+")");
  //  const use = this.createElement('use');
  //  use.setAttribute('href', "#log-outline");
  //  g.appendChild(use);
  //});
}

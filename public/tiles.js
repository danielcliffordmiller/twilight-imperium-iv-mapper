
"use strict";

$(document).ready(function() {
    $(".hand").click(function(event) {
	$(".selected").removeClass("selected");
	$("."+this.id).addClass("selected");
	$(this).addClass("selected");
    });
    $(".map").click(function(event) {
        if ($(this).hasClass("selected")) alert("click on: "+this.id);
    });
});

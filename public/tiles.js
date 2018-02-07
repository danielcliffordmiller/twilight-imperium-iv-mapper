
"use strict";

$(document).ready(function() {
    $(".hand").click(function(event) {
	$(".selected").removeClass("selected");
	$("."+this.id).addClass("selected");
	$(this).addClass("selected");
    });
});

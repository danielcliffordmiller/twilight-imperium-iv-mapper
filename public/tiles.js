
"use strict";

var selected;
var removePreviousSelected = function() {
    removePreviousSelected = function() {
	selected.removeClass("selected")
    }
}
$(document).ready(function() {
    $(".hand").click(function(event) {
	removePreviousSelected()
	$(".hand").removeClass("selected");
	selected = $("."+this.id);
	selected.addClass("selected");
	$(this).addClass("selected");
    });
});

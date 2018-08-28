"use strict";
$(document).ready(function(){
  $("input[type=text]").keyup(function(e){
    if(/^\s*$/.test(this.value)) {
      $("label[for="+this.id+"]").addClass("empty");
    } else {
      this.dispatchEvent(new Event('data'));
      $("label[for="+this.id+"]").removeClass("empty");
    }
  });
});

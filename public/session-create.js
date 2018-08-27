"use strict";
$(document).ready(function(){
  $("input[type=text]").keyup(function(e){
    if(/^\s*$/.test(e.target.value)) {
      e.target.labels.forEach( (l) => $(l).addClass("empty") );
    } else {
      e.target.labels.forEach( (l) => $(l).removeClass("empty") );
    }
  });
});

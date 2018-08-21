"use strict";
const sidebarState = new (function() {
  const sidebarFit = function() {
    return $(window).width() + 10 > $("#container").width() + $("#sidebar").width() ;
  };
  const clickOpen = function() {
    $(".sb").removeClass("sb-closed");
    $(".sb").addClass("sb-open");
    this.handleClick = clickClose.bind(this);
    this.handleResize = resizeOpen.bind(this, clickOpen.bind(this));
    this.restore = resizeClose.bind(this, clickOpen.bind(this));
  };
  const clickClose = function() {
    $(".sb").removeClass("sb-open");
    $(".sb").addClass("sb-closed");
    this.handleClick = clickOpen.bind(this);
    this.handleResize = resizeOpen.bind(this, clickClose.bind(this));
    this.restore = resizeClose.bind(this, clickClose.bind(this));
  };
  const resizeOpen = function(fn) {
    if( sidebarFit() ) {
      $(".sb").removeClass("sb-open sb-closed");
      $("#sidebar").addClass("sb-open");
      this.handleResize = resizeClose.bind(this, fn);
      this.restore = resizeOpen.bind(this, fn);
    }
  };
  const resizeClose = function(fn) {
    if( !sidebarFit() ) {
      fn();
      this.handleResize = resizeOpen.bind(this, fn);
      this.restore = resizeClose.bind(this, fn);
    }
  };
  this.init = function() {
    clickClose.call(this);
    if( sidebarFit() ) {
      resizeOpen.call(this, clickClose.bind(this));
    } else {
      resizeClose.call(this, clickClose.bind(this));
    }
  }.bind(this);
})();
$(document).ready(function(){
  sidebarState.init();
  $(window).resize(function() { sidebarState.handleResize(); });
});
Intercooler.ready(function(){
  sidebarState.restore();
});

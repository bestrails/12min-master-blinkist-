// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require jquery.ui.autocomplete
//= require jquery.mousewheel
//= require jquery.jscrollpane.min
//= require jquerypp.custom
//= require modernizr.custom
//= require jquery.bookblock
//= require page
//= require masonry.pkgd.min
//= require EventListener
//= require classie
//= require modernizr.uisearch.custom
//= require uisearch
//= require i18n/translations
//= require i18n
//= require jquery.remotipart
//= require jquery.tagsinput.min
//= require pagedown_bootstrap
//= require pagedown_init
//= require override
//= require jquery.payment
//= require social-share-button

//= require_tree .


$(document).ready(function() {
      $('#select').bind('change', function () {
            var url = $(this).val(); // get selected value
            if (url) { // require a URL
                window.location = url; // redirect
            }
            return false;
        });
    });
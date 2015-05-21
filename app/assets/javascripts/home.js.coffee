# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$("ul.top-menu__right li a").on 'click', () ->
  $("ul.top-menu__right li").removeClass('active')
  $(this).parent().addClass('active')

new UISearch(document.getElementById("sb-search"))
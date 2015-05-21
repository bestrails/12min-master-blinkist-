# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('.libray-menu__container .top-menu__item a').on 'click', () ->
    $('.libray-menu__container .top-menu__item').removeClass('active')
    $(this).parent().addClass('active')

  $('.info-close').on 'click', () ->
    $(this).closest('.notification__trial-started').hide()
    nextDiv = $('.notification__trial-started').next()
    
    $('.notification__trial-started').hide();
    
    top = nextDiv.css('top')
    classes = nextDiv.attr('class').split(' ');
    
    nextDivs = $("." + classes[classes.length - 1] + "[style*='top: " + top + "']")
    nextDivs.each (idx) ->
      $(nextDivs[idx]).css('top', '0')

    $('.no-books-message').css('top', '0')
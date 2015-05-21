# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.msnry = new Masonry(".dynamic-grid__container", {
  columnWidth: 258,
  itemSelector: '.dynamic-grid__element'
})

$ ->
  if $('.create__library__header__container').length > 0
    
    $('footer .container').css('margin-top', '0px')
  $('#search.sb-search-input').on 'keyup', ->
    search = $(this).val()
    $.ajax(
      url: "/books",
      data: { search: search },
      dataType: "json"
    ).done (books) ->
      $('.search__results').css('display', 'none')
      $('.search__results .search__results__found-results li').remove()
      $('.search__results .search__results__no-result').css('display', 'block')
      $('.search__results .search__results__found-results').css('display', 'block')

      if books.length > 0
        $.each books, ->
          li = """
                <li>
                  <a href="/#{this.slug}" data-remote="true">
                      <span class="search__results__title"><em>#{this.title}</em></span>
                      <span class="search__results__sourceAuthor"><em>#{this.author}</em></span>
                  </a>
                </li>
              """
          $('.search__results .search__results__found-results').append(li)
        
        $('.search__results .search__results__found-results li a').on 'mouseover', () ->
          $('.search__results .search__results__found-results li a').removeClass('hovered')
          $(this).addClass('hovered')

        $('.search__results .search__results__found-results li a').on 'click', () ->
          $('.search__results').css('display', 'none')

        $('.search__results .search__results__no-result').css('display', 'none')
      else
        $('.search__results .search__results__found-results').css('display', 'none')

      $('.search__results').css('display', 'block')
      return

 $('#sb-search .sb-icon-search').on 'click', (e) ->
    search_container = $(this).closest('div')
    

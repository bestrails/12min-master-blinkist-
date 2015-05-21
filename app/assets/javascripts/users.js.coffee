$ ->
  $(document).on "ajax:before", "#edit-user", ->
    name = $("#mailbox", this).val()
    domain = $("#mailbox", this).data('append')

    kindle = name + domain.replace(/^\s+|\s+$/g, '')

    $("#mailbox", this).val(kindle)
    $('#simplemodal-container').modal('hide')
    $('body').removeClass('modal-open')
    $('.modal-backdrop').remove()
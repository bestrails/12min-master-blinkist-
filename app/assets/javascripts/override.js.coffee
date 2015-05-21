# Override Rails handling of confirmation

$.rails.allowAction = (element) ->
  # The message is something like "Are you sure?"
  message = element.data('confirm')
  title = element.data('title')
  # If there's no message, there's no data-confirm attribute, 
  # which means there's nothing to confirm
  return true unless message
  # Clone the clicked element (probably a delete link) so we can use it in the dialog box.
  
  $link = element.clone()
    .removeAttr('class')
    .removeAttr('data-confirm')
    .addClass('btn').addClass('btn-danger')
    .html(I18n.t('users.destroy.modal.confirm.yes'))

  # Create the modal box with the message
  modal_html = """
               <div class="modal fade" id="confirmationModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                <div class="modal-dialog">
                  <div class="modal-content">
                    <div class="modal-header">
                      <a class="close" data-dismiss="modal">×</a>
                      <h3>#{title}</h3>
                    </div>
                    <div class="modal-body">
                      <p>#{message}</p>
                    </div>
                    <div class="modal-footer">
                      <a data-dismiss="modal" class="btn">"""+I18n.t('users.destroy.modal.confirm.cancel')+"""</a>
                    </div>
                  </div>
                </div>
               </div>
               """
  $modal_html = $(modal_html)
  # Add the new button to the modal box
  $modal_html.find('.modal-footer').append($link)
  # Pop it up
  $modal_html.modal()
  # Prevent the original link from working
  return false
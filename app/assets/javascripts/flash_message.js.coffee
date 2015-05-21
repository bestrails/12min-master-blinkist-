show_ajax_message = (msg, type) ->
  alert = """
    <div class='alert alert-#{type} alert-dismissable'>
      <button type='button' class='close' data-dismiss='alert' aria-hidden='true'>&times;</button>
      #{msg}
    </div>
  """
  $("#flash-message").html alert
  $("#flash-message .alert-#{type}").delay(5000).slideUp 'slow'

$(document).ajaxComplete (event, request) ->
  try 
    msg = decodeURIComponent(request.getResponseHeader("X-Message"))
  catch e 
    msg = unescape(request.getResponseHeader("X-Message"))
  
  type = request.getResponseHeader("X-Message-Type")
  
  if msg != 'null' && msg != null
    show_ajax_message msg, type #use whatever popup, notification or whatever plugin you want
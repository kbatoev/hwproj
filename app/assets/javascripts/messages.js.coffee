source = new EventSource('/messages/events')
source.addEventListener 'message', (e) ->
  message = $.parseJSON(e.data).message
  $("#chat").append("<%= escape_javascript (render partial: 'tasks/message', object: message) %>");
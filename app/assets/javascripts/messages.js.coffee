source = new EventSource('/messages/events')
source.addEventListener 'message', (e) ->
  message = $.parseJSON(e.data)
  $("#chat").append("#{message.text}");
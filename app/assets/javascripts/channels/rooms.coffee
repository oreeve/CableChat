jQuery(document).on 'turbolinks:load', ->
  messages = $('#messages')

  if $('#messages').length > 0
    messages_to_bottom = -> messages.scrollTop(messages.prop("scrollHeight"))

    messages_to_bottom()

    App.global_chat = App.cable.subscriptions.create {
        channel: "ChatRoomsChannel"
        chat_room_id: messages.data('chat-room-id')
      },
      connected: ->
        # Called when the subscription is ready for use on the server

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (data) ->
        messages.append data['message']
        messages_to_bottom()

      send_message: (message, chat_room_id) ->
        @perform 'send_message', message: message, chat_room_id: chat_room_id

      delete_message: (message_id) ->
        @perform 'delete_message', message_id: message_id

    $('#new_message').submit (e) ->
      $this = $(this)
      textarea = $this.find('#message_body')
      if $.trim(textarea.val()).length > 0
        App.global_chat.send_message textarea.val(), messages.data('chat-room-id')
        location.reload();
      else
        $('.new_message').before('<p class="message-error">Uhh... Enter a message, maybe?</p>')
      textarea.val('')
      e.preventDefault()
      return false

    $('.delete-message').click ->
      App.global_chat.delete_message $(this).find('#message-X').data('message-id')
      location.reload();

    $('.message-box').keypress (e) ->
      if e.which == 13
        $(this).closest('form').submit()

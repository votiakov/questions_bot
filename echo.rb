require 'telegram/bot'

token = '151981338:AAHdsYpinvHx5L6_UBqnr9Sy5CKUsivOXqo'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/hi'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}! Welcome to http://votiakov.com")
    end
  end
end
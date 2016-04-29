require './models/user'
require './lib/message_sender'
require './lib/questions'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.find_or_create_by(uid: message.from.id)
  end

  def respond
    on /^\/help/ do
      answer_with_message "Hello, #{message.from.first_name}! I have 50 questions for you. These questions can change your mind and make you a better person. Please read carefully, take your time to think and then give an honest answer to yourself. \n Send '/begin' to start, '/next' to get the next question. If you leave the conversation - I will remember the last question I asked, and next time I will begin with the next question. So don't worry :) If you want me to forget what was the last question and start from the beginning - just type '/forget'. Enjoy!"
    end
    # on /^\/start/ do
    #   answer_with_greeting_message
    # end

    # on /^\/stop/ do
    #   answer_with_farewell_message
    # end

    # on /^\/morning/ do
    #   answer_with_message "Good morning, #{message.from.first_name}!"
    # end

    # on /^\/motivate/ do
    #   answer_with_message "Ok, #{message.from.first_name}! You will get your motivation ;)"
    # end

    # on /^\/advice/ do
    #   answer_with_message "In which field do you want my advice?"
    # end

    on /^\/begin/ do
      answers = [ "/next" ]
      if user.last_asked.nil?
        answer_with_buttons("Ok. I will ask you 50 questions. You should think about it deeply and only when you are sure you know the answer - you can move to the next question. If you leave our conversation - I will remember the last question I asked. If you want me to start - click send '/next' or just click one of the buttons below.", answers)
      elsif user.last_asked >= 0
        answer_with_message "I hope you liked the previous question I asked ;) Here is your next question! \n"
        ask_and_increment
      end

    end

    on /^\/stop/ do
      answer_with_message "Of course, you need time to give an answer ;) Come back when you are ready!"
    end

    on /^\/next/ do
      ask_and_increment
    end

    on /^\/forget/ do
      user.last_asked = nil
      user.save
      answer_with_message "Ok, #{message.from.first_name}. I forgot what was the last question I asked. May I start from the beginning then? /begin"
    end
  end

  private

  def on regex, &block
    regex =~ message.text

    if $~
      case block.arity
      when 0
        yield
      when 1
        yield $1
      when 2
        yield $1, $2
      end
    end
  end

  def ask_and_increment
    user.last_asked ||= 0

    ask_question(user.last_asked)

    user.last_asked += 1
    user.save
  end

  def ask_question(index)
    # answer_with_message("#{QUESTIONS[index]}")
    answer_with_buttons("#{QUESTIONS[index]}", [ "/stop", "/next" ])
  end

  def answer_with_greeting_message
    answer_with_message I18n.t('greeting_message')
  end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message')
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end

  def answer_with_buttons(text, answers)
    MessageSender.new(bot: bot, chat: message.chat, text: text, answers: answers).send
  end
end

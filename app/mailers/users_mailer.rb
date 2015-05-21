class UsersMailer < ActionMailer::Base 
  def accepted_invite(user)
    @user = user

    I18n.locale = I18n.default_locale

    mail to: @user.email
  end

  def send_to_pocket(email, link)
    @email = email
    @link = link

    I18n.locale = I18n.default_locale

    mail to: ENV['POCKET_EMAIL']
  end

  def send_to_kindle(email, book)
    I18n.locale = I18n.default_locale

    attachments["#{book.slug}.html"] = book.summary

    mail from: ENV['KINDLE_EMAIL'], to: email, body: ''
  end
end
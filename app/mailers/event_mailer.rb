class EventMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.event_mailer.event_created.subject
  #
  def event_created(event, recipient)
    @event = event
    @recipient = recipient

    mail(
      to: @recipient.email,
      subject: "【Darts Events】イベントを作成しました：#{@event.title}"
    )
  end
end

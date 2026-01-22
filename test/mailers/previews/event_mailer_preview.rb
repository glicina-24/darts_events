# Preview all emails at http://localhost:3000/rails/mailers/event_mailer
class EventMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/event_mailer/event_created
  def event_created
    EventMailer.event_created
  end
end

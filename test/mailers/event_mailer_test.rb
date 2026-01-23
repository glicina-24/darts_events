require "test_helper"

class EventMailerTest < ActionMailer::TestCase
  test "event_created" do
    event = events(:one)      # fixtures 使ってるなら
    recipient = users(:one)

    notification_context = {
      reasons: [ "favorite_shop" ],
      shop_name: event.shop.name,
      pro_names: [ "山田" ]
    }

    mail = EventMailer.event_created(event, recipient, notification_context)

    assert_equal [ recipient.email ], mail.to
    assert_match event.title, mail.subject
  end
end

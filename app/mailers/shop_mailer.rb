class ShopMailer < ApplicationMailer
  def email_verification(shop, raw_token)
    @shop = shop
    @verification_url = verify_email_shop_url(shop, token: raw_token)

    mail(
      to: @shop.contact_email,
      subject: "【Darts Events】メール確認のお願い"
    )
  end
end

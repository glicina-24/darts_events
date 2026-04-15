# 壊れた multipart/form-data を 400 で返し、追跡用情報をログに残す
class CatchBadMultipart
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue Rack::Multipart::Error => e
    request = Rack::Request.new(env)
    request_id = env["action_dispatch.request_id"]
    forwarded_for = env["HTTP_X_FORWARDED_FOR"]
    user = env["warden"]&.user
    user_id = user&.id

    Rails.logger.warn(
      "[bad_multipart] class=#{e.class} message=#{e.message.inspect} " \
      "request_id=#{request_id} method=#{request.request_method} path=#{request.path} " \
      "ip=#{request.ip} xff=#{forwarded_for.inspect} ua=#{request.user_agent.inspect} " \
      "content_type=#{request.content_type.inspect} content_length=#{request.content_length.inspect} " \
      "user_id=#{user_id.inspect}"
    )

    [ 400, { "Content-Type" => "text/plain; charset=utf-8" }, [ "Bad Request" ] ]
  end
end

Rails.application.config.middleware.insert_before(
  ActionDispatch::ShowExceptions,
  CatchBadMultipart
)

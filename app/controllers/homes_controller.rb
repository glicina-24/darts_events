class HomesController < ApplicationController
  def index
    now        = Time.current
    week_start = now.beginning_of_week(:monday)
    week_end   = now.end_of_week(:monday)

    case_sql = ActiveRecord::Base.sanitize_sql_array(
      [ "CASE WHEN start_datetime BETWEEN ? AND ? THEN 0 ELSE 1 END", week_start, week_end ]
    )

    @top_events = Event.includes(:shop, images_attachments: :blob)
      .where("start_datetime >= ?", now)
      .order(Arel.sql(case_sql))
      .order(start_datetime: :asc)
      .limit(3)
  end
end

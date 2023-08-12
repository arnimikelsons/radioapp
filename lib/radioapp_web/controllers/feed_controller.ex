defmodule RadioappWeb.FeedController do
  use RadioappWeb, :controller
  alias Radioapp.Station
  # alias RadioappWeb.ShowTimeHelper

  def index(conn, _params) do
    now = DateTime.to_naive(Timex.now("America/Toronto"))
    time_now = DateTime.to_time(Timex.now("America/Toronto"))
    weekday = Timex.weekday(now)

    show_name = Station.get_program_from_time(weekday, time_now)

    # if now in Timex.Interval.new(from: ~N[2022-12-04 00:00:00], until: ~N[2022-12-04 02:23:45]) do
    #  "TEsting for a show name"
    # else
    #  "oops"
    # end

    # show_time = ShowTimeHelper.current_show_time()

    render(conn, "index.html", show_name: show_name)
  end
end

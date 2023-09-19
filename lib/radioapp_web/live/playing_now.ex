defmodule RadioappWeb.PlayingNow do
  use RadioappWeb, :live_view
  alias Radioapp.Station

  def render(assigns) do
    ~H"""
      <span></span>
    """
  end

  def playing_now(assigns) do

    tenant = assigns.tenant
    IO.inspect(tenant, label: "TENANT NAME IN PLAYING NOW (CONTROLLER)")
    now = DateTime.to_naive(Timex.now("America/Toronto"))
    time_now = DateTime.to_time(Timex.now("America/Toronto"))
    weekday = Timex.weekday(now)
    assigns = assign(assigns, :show_name, Station.get_program_from_time(weekday, time_now, tenant))

    IO.inspect(assigns.show_name, label: "SHOW_NAME IN PLAYING NOW (CONTROLLER)")
    IO.inspect(Station.get_program_from_time(weekday, time_now, tenant), label: "GET PROGRAM FROM TIME")
  ~H"""
    <span><%= @show_name %></span>
  """
  end
end

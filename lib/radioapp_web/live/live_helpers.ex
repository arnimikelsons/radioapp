defmodule RadioappWeb.LiveHelpers do
  use RadioappWeb, :live_view

  alias Radioapp.Accounts
  alias Radioapp.Accounts.User

  def assign_stationdefaults(session, socket) do
    socket =
      socket
      |> assign_new(:current_user, fn ->
        find_current_user(session)
      end)

    socket
  end

  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end

  # def normalize_log_datetimes(log_params, timezone) do
  #   date = DateTime.to_date(log_)


  #   log_params
  # end
  def normalize_segment_datetimes(segment_params, %{start_datetime: log_start_datetime}, %{timezone: timezone}) do
    date = DateTime.to_date(log_start_datetime)
    case segment_params do
      %{"start_time" => start_time_param, "end_time" => end_time_param} ->
        {:ok, start_time} = Time.from_iso8601(start_time_param)
        {:ok, end_time} = Time.from_iso8601(end_time_param)
        {:ok, start_datetime} = DateTime.new(date, start_time, timezone)
        {:ok, end_datetime} = DateTime.new(date, end_time, timezone)
        Map.put(segment_params, "start_datetime", start_datetime)
        Map.put(segment_params, "end_datetime", end_datetime)
        segment_params
      %{"start_time" => start_time_param} ->
        {:ok, start_time} = Time.from_iso8601(start_time_param)
        {:ok, start_datetime} = DateTime.new(date, start_time, timezone)
        Map.put(segment_params, "start_datetime", start_datetime)
        segment_params
      %{} ->
        segment_params
    end
  end

end

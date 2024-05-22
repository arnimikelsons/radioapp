defmodule RadioappWeb.Api.SongController do
  use RadioappWeb, :controller

  alias Radioapp.Station
  alias Radioapp.Station.PlayoutSegment
  alias Radioapp.Admin

  action_fallback RadioappWeb.FallbackController

  def index(conn, _song_params) do
    tenant = RadioappWeb.get_tenant(conn)
    dbg("index called")
    playout_segments = Station.list_playout_segments(tenant)
    render(conn, :index, playout_segments: playout_segments)
  end

  def new(conn, %{"artist" => artist, "title" => title}) do
    tenant = RadioappWeb.get_tenant(conn)
    dbg("new called")

    #Get the start time based on the time it is now in the tenant's time zone
    %{timezone: timezone} = Admin.get_timezone!(tenant)
    time_now = DateTime.to_time(Timex.now(timezone))

    with {:ok, %PlayoutSegment{} = playout_segment} <- Station.create_playout_segment(%{song_title: title, artist: artist, start_time: time_now}, tenant) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/songs/#{playout_segment}")
      |> render(:show, playout_segment: playout_segment)
    end

  end

  def show(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)

    playout_segment = Station.get_playout_segment!(id, tenant)
    render(conn, :show, playout_segment: playout_segment)
  end

  # def create(conn, song_params) do

  #   tenant = RadioappWeb.get_tenant(conn)
  #   log = Station.get_log!(5, tenant)
  #   dbg("create called")

  #   with {:ok, %Segment{} = segment} <- Station.create_segment_api(log, song_params, tenant) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", ~p"/api/songs/#{segment}")
  #     |> render(:show, song: segment)
  #   end
  # end

  # def update(conn, %{"id" => id, "song" => song_params}) do
  #   song = Play.get_song!(id)

  #   with {:ok, %Song{} = song} <- Play.update_song(song, song_params) do
  #     render(conn, :show, song: song)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   song = Play.get_song!(id)

  #   with {:ok, %Song{}} <- Play.delete_song(song) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end

end

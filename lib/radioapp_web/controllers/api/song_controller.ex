defmodule RadioappWeb.Api.SongController do
  use RadioappWeb, :controller

  alias Radioapp.Station
  alias Radioapp.Station.Segment

  action_fallback RadioappWeb.FallbackController

  def index(conn, _song_params) do
    tenant = RadioappWeb.get_tenant(conn)
    log = Station.get_log!(5, tenant)
    dbg("index called")
    segments = Station.list_segments_for_log(log, tenant)
    render(conn, :index, segments: segments)
  end

  # def index(conn, song_params) do
  def new(conn, %{"artist" => artist, "title" => title, "token" => "145876"}) do
    tenant = RadioappWeb.get_tenant(conn)
    log = Station.get_log!(5, tenant)

    dbg("new called")

    with {:ok, %Segment{} = segment} <- Station.create_segment_api(log, %{song_title: title, artist: artist}, tenant) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/songs/#{segment}")
      |> render(:show, segment: segment)
    end

  end

  def create(conn, song_params) do

    tenant = RadioappWeb.get_tenant(conn)
    log = Station.get_log!(5, tenant)
    dbg("create called")

    with {:ok, %Segment{} = segment} <- Station.create_segment_api(log, song_params, tenant) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/songs/#{segment}")
      |> render(:show, song: segment)
    end

  end

  def show(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)

    segment = Station.get_segment!(id, tenant)
    render(conn, :show, segment: segment)
  end

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

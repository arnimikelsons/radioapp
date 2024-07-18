defmodule RadioappWeb.Api.SongController do
  use RadioappWeb, :controller

  alias Radioapp.Station
  alias Radioapp.Station.PlayoutSegment
  alias Radioapp.Admin

  action_fallback RadioappWeb.FallbackController

  def index(conn, _song_params) do
    tenant = RadioappWeb.get_tenant(conn)
    playout_segments = Station.list_playout_segments(tenant)
    render(conn, :index, playout_segments: playout_segments)
  end

     # Playout System API with Source String
     def new(conn, %{"artist" => artist, "title" => title, "source" => source}) do
      tenant = RadioappWeb.get_tenant(conn)

      #Get the start time based on the time it is now in the tenant's time zone
      %{timezone: timezone} = Admin.get_timezone!(tenant)
      time_now = DateTime.to_time(Timex.now(timezone))

      with {:ok, %PlayoutSegment{} = playout_segment} <- Station.create_playout_segment(%{song_title: title, artist: artist, start_time: time_now, source: source}, tenant) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/songs/#{playout_segment}")
        |> render(:show, playout_segment: playout_segment)
      end
    end

  # Playout System API
  def new(conn, %{"artist" => artist, "title" => title}) do
    tenant = RadioappWeb.get_tenant(conn)

    #Get the start time based on the time it is now in the tenant's time zone
    %{timezone: timezone} = Admin.get_timezone!(tenant)
    time_now = DateTime.to_time(Timex.now(timezone))

    with {:ok, %PlayoutSegment{} = playout_segment} <- Station.create_playout_segment(%{song_title: title, artist: artist, start_time: time_now, source: "Unknown"}, tenant) do
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

  # POST requests received from ACR Cloud
  def create(conn, song_params) do
    # This code works with one artist and one music entry
    # %{ "data" => %{"metadata" => %{"music" => [%{"title" => title, "artists" => [%{"name" => artist}]}]}}} = song_params
    %{ "data" => %{"metadata" => %{"music" => music }}} = song_params
    first_entry = Enum.take(music, 1)
    [%{"title" => title, "artists" => artists_list }] = first_entry
    first_artist = Enum.take(artists_list, 1)
    [%{"name" => artist}] = first_artist

    tenant = RadioappWeb.get_tenant(conn)
    %{timezone: timezone} = Admin.get_timezone!(tenant)
    time_now = DateTime.to_time(Timex.now(timezone))

    with {:ok, %PlayoutSegment{} = playout_segment} <- Station.create_playout_segment(%{artist: artist, song_title: title, start_time: time_now, source: "ACR Cloud"}, tenant) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/songs/#{playout_segment}")
      |> render(:show, playout_segment: playout_segment)
    end

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

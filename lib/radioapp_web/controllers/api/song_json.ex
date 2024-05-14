defmodule RadioappWeb.Api.SongJSON do

  # alias Data.Play.Song

  alias Radioapp.Station.Segment

  @doc """
  Renders a list of songs.
  """
  def index(%{segments: segments}) do
    %{data: for(segment <- segments, do: data(segment))}
  end

  @doc """
  Renders a single song.
  """
  def show(%{segment: segment}) do
    %{data: data(segment)}
  end

  defp data(%Segment{} = segment) do
    %{
      id: segment.id,
      artist: segment.artist,
      song_title: segment.song_title
    }
  end
end

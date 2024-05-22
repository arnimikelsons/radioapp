defmodule RadioappWeb.Api.SongJSON do

  # alias Data.Play.Song

  alias Radioapp.Station.PlayoutSegment

  @doc """
  Renders a list of songs.
  """
  def index(%{playout_segments: playout_segments}) do
    %{data: for(playout_segment <- playout_segments, do: data(playout_segment))}
  end

  @doc """
  Renders a single song.
  """
  def show(%{playout_segment: playout_segment}) do
    %{data: data(playout_segment)}
  end

  defp data(%PlayoutSegment{} = playout_segment) do
    %{
      id: playout_segment.id,
      artist: playout_segment.artist,
      song_title: playout_segment.song_title,
      start_time: playout_segment.start_time
    }
  end
end

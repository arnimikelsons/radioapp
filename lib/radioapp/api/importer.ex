defmodule Radioapp.API.Importer do

  alias Radioapp.Station

  def save_playout_segments_to_log(log, playout_segments, tenant) do

    Enum.each(playout_segments, fn(playout_segment) ->

      Station.create_segment_relaxed(
       log,
        %{
          "artist" => playout_segment.artist,
          "song_title" => playout_segment.song_title,
          "start_datetime" => playout_segment.inserted_at
        },
        tenant)

    end)
  end


end

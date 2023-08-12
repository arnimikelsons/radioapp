defmodule Radioapp.Station.SegmentTest do
  use Radioapp.DataCase, async: true

  alias Radioapp.Station.Segment

  test "duration can be with format" do
    assert convert("12345") == 12345
    assert convert("10h") == 10 * 60 * 60
    assert convert("1h10m") == 60 * 60 + 10 * 60
    assert convert("23h59m50s") == 23 * 60 * 60 + 59 * 60 + 50
    assert convert("40m4s") == 40 * 60 + 4
    assert convert("4s") == 4
    assert convert("4m") == 4 * 60
    assert convert("1h2") == nil
    assert convert("wrong") == nil
  end

  defp convert(duration) do
    changeset = Segment.changeset(%Segment{}, %{duration: duration})
    Ecto.Changeset.get_change(changeset, :duration)
  end
end

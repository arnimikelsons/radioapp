defmodule Radioapp.CSV.ImporterTest do
  use Radioapp.DataCase

  alias Radioapp.CSV.Importer
  alias Radioapp.Factory

  @tenant "sample"
  @prefix Triplex.to_prefix(@tenant)

  test "Uploading a CSV that is missing a required column" do
    log = Factory.insert(:log, [], prefix: @prefix)

    data = [
      ["artist"],
      ["bon jovi"],
      ["ben"]
    ]

    Importer.csv_row_to_table_record(data, log, @tenant)

    # TODO assert on the error
  end

  test "Uploading a CSV that has both required columns" do
    log = Factory.insert(:log, [], prefix: @prefix)

    data = [
      ["artist", "song_title"],
      ["bon jovi", "blah"],
      ["ben", "blah"]
    ]

    Importer.csv_row_to_table_record(data, log, @tenant)

    # TODO assert that those two things are added to the log
  end
end
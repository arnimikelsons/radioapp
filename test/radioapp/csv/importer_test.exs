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

    assert Importer.csv_row_to_table_record(data, log, @tenant) == {:error, "The CSV file contained error(s) in the column names."}

  end

  # Fix this test, and probably fix the import
  # test "Uploading a CSV that has both required columns" do
  #   log = Factory.insert(:log, [], prefix: @prefix)

  #   data = [
  #     ["artist", "song_title"],
  #     ["bon jovi", "blah"],
  #     ["ben", "blah"]
  #   ]

  #   Importer.csv_row_to_table_record(data, log, @tenant)

  #   # TODO assert that those two things are added to the log
  # end
end

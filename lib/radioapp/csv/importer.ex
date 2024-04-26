defmodule Radioapp.CSV.Importer do

  alias Radioapp.Station

  def csv_row_to_table_record(data, log, tenant) do
    column_names = get_column_names(data)

    data
      |> Enum.drop(1) # Drop the first row from the stream
      |> Enum.map(fn row ->
        row
        |> Enum.with_index() # Add an index to each cell value
        |> Map.new(fn {val, num} -> {column_names[num], val} end)
        |> add_segment_to_log(log, tenant)
      end)
  end

  defp get_column_names(data) do
    data
      |> Enum.fetch!(0) # Gets the first row of the stream
      |> Enum.with_index() # Adds an index integer to it, creating tuples
      |> Map.new(fn {val, num} -> {num, val} end)
  end

  defp add_segment_to_log(row, log, tenant) do
    Station.create_segment(log, row, tenant)

  end
end

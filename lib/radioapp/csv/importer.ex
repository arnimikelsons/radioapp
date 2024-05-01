defmodule Radioapp.CSV.Importer do

  alias Radioapp.Station
  alias Radioapp.Admin

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
    row = add_category_id_to_attrs(row, tenant)

    case Station.create_segment(log, row, tenant) do
      {:ok, segment} ->
        dbg(segment)
      {:error, msg} ->
        dbg(msg)
    end

  end

  defp add_category_id_to_attrs(row, tenant) do
    list_categories = Admin.list_categories_dropdown(tenant)
    dbg(list_categories)
    case Enum.find(list_categories, fn tuple ->
          String.contains?(
            row["category"],
            [List.first(
                elem(tuple, 0)),
                List.last(elem(tuple, 0))]
          )
        end) do
      {_category_string, category_id} ->
        Map.put(row, "category_id", category_id)

      nil ->
        {:error}
    end

    # Map.put(row, "category_id", category_id)
  end
end

defmodule Radioapp.CSV.Importer do

  alias Radioapp.Station
  alias Radioapp.Admin

  @segment_columns [
    "artist",
    "can_con",
    "catalogue_number",
    "category",
    "start_time",
    "end_time",
    "hit",
    "instrumental",
    "new_music",
    "socan_type",
    "song_title",
    "indigenous_artist",
    "emerging_artist"
  ]

  # @required_columns [
  #   "artist",
  #   "end_time",
  #   "start_time",
  #   "song_title",
  #   "category"
  # ]

  @relaxed_required_columns [
    "artist",
    "song_title"
  ]

  def csv_row_to_table_record(data, log, tenant) do
    column_names = get_column_names(data)
    case column_names_match_db(column_names) do
      false ->
        {:error, "The CSV file contained error(s) in the column names."}
      true ->
        result = data
          |> Enum.drop(1) # Drop the first row from the stream
          |> Enum.map(fn row ->
            row
            |> Enum.map(fn cell ->
                case cell do
                  "TRUE" ->
                    "true"
                  "FALSE" ->
                    "false"
                  _ ->
                    cell
                end
              end)
            |> Enum.with_index() # Add an index to each cell value
            |> Map.new(fn {val, num} -> {column_names[num], val} end)
            |> add_segment_to_log(log, tenant)
          end)

        case Enum.find(result, nil, fn x -> x == :error end) do
          nil ->
            {:ok, "data added successfully"}
          :error ->
            {:error, "The CSV file contained error(s)."}
        end
    end
  end

  defp get_column_names(data) do
    data
      |> Enum.fetch!(0) # Gets the first row of the stream
      |> Enum.with_index() # Adds an index integer to it, creating tuples
      |> Map.new(fn {val, num} -> {num, val} end)
  end

  defp column_names_match_db(column_names) do
    csv_cols = Map.values(column_names)
    case Enum.all?(csv_cols, fn csv_col ->
          Enum.member?(@segment_columns, csv_col)
        end)
        &&
        Enum.all?(@relaxed_required_columns, fn required_col ->
          Enum.member?(csv_cols, required_col)
        end)
    do
      false ->
        false
      true ->
        true
    end


  end

  defp add_segment_to_log(row, log, tenant) do

    row = add_category_id_to_attrs(row, tenant)

    case Station.create_segment_relaxed(log, row, tenant) do
      {:ok, _segment} ->
        :ok
      {:error, _msg} ->
        :error
    end

  end

  defp add_category_id_to_attrs(row, tenant) do
    list_categories = Admin.list_categories_dropdown(tenant)
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
        row
    end
  end

end

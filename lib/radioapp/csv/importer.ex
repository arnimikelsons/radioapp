defmodule Radioapp.CSV.Importer do

  def csv_row_to_table_record(data) do
    column_names = get_column_names(data)

  end

  defp get_column_names(data) do
    data = data
      |> Enum.fetch!(0)

    dbg(data)
  end
end

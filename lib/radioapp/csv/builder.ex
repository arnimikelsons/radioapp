defmodule Radioapp.CSV.Builder do
  def to_csv(headers, records) do
    ([headers] ++ records)
    |> CSV.encode()
    |> Enum.to_list()
  end

  def to_csv2(headers, records) do
    rows =
      Enum.reduce(records, [], fn record, acc ->
        row =
          Enum.map(headers, fn header ->
            Map.get(record, header)
          end)

        acc ++ [row]
      end)

    ([headers] ++ rows)
    |> CSV.encode()
    |> Enum.to_list()
  end

  def generate_log(_params) do
    #very beginning of this
    #from(s in Segment,
    #  join: l in assoc(s, :log),
    #  join: p in assoc(l, :program),
    #  where: l.date >= ^params.start_date,
    #  where: l.date <= ^params.end_date,
    #  order_by: [asc: l.date, asc: s.start_date]
    #)
    #families =
    #  Repo.all(query, prefix: prefix)
    #  |> Repo.preload([:children, :familytypes])

    #%__MODULE__{}
    #|> calculate_headers(families)
    #|> format_records(families)
  end



end

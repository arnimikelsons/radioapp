defmodule RadioappWeb.LogController do
  use RadioappWeb, :controller

  alias Radioapp.{Station, Admin}
  alias Radioapp.CSV.Builder

  defmodule SearchParams do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :start_date, :date
      field :end_date, :date
      field :filter, :string, default: "all"
    end

    def new(%{} = params) do
      today = Date.utc_today()
      beginning_of_last_week = Station.previous_week(Date.beginning_of_week(today))
      end_of_last_week = Station.previous_week(Date.end_of_week(today))

      changeset(
        %__MODULE__{
          start_date: beginning_of_last_week,
          end_date: end_of_last_week
        },
        params
      )
    end

    def changeset(search, %{} = params) do
      search
      |> cast(params, [:start_date, :end_date, :filter])
      |> validate_required([:start_date, :end_date])
    end

    def apply(search) do
      apply_changes(search)
    end
  end

  def index(conn, _params) do
    search = SearchParams.new(%{})
    tenant = RadioappWeb.get_tenant(conn)
    current_user = conn.assigns.current_user
    user_role=Admin.get_user_role(current_user, tenant)
    render(conn, "index.html", search: search, logs: [], user_role: user_role)
  end

  def search(conn, %{"search_params" => params}) do
    search = SearchParams.new(params)
    tenant = RadioappWeb.get_tenant(conn)
    current_user = conn.assigns.current_user
    logs =
      if search.valid? do
        Station.list_full_logs(SearchParams.apply(search), tenant)
      else
        []
      end
    user_role=Admin.get_user_role(current_user, tenant)

    render(conn, "index.html", search: search, logs: logs, user_role: user_role)
  end

  def charts(conn, _params) do
    search = SearchParams.new(%{"filter" => "all"})
    tenant = RadioappWeb.get_tenant(conn)
    current_user = conn.assigns.current_user
    user_role=Admin.get_user_role(current_user, tenant)
    render(conn, "charts.html", search: search, charts: [], user_role: user_role)
  end

  def search_charts(conn, %{"search_params" => params}) do
    search = SearchParams.new(params)
    tenant = RadioappWeb.get_tenant(conn)
    current_user = conn.assigns.current_user
    applied = SearchParams.apply(search)
    charts =
      if search.valid? do
        Station.list_charts(applied, applied.filter, tenant)
      else
        []
      end

    user_role=Admin.get_user_role(current_user, tenant)
    render(conn, "charts.html", search: search, charts: charts, user_role: user_role)
  end

  def chart_detail(conn, params) do
      %{"chart" => %{
        "artist" => artist,
        "count" => count,
        "end_date" => end_date,
        "song_title" => song_title,
        "start_date" => start_date
      }} = params
    tenant = RadioappWeb.get_tenant(conn)
    current_user = conn.assigns.current_user
    user_role=Admin.get_user_role(current_user, tenant)
    details = Station.list_chart_detail(params, tenant)

    render(conn, "charts_detail.html", artist: artist, song_title: song_title, count: count, start_date: start_date, end_date: end_date, user_role: user_role, details: details)
  end


  def export(conn, %{"search_params" => params}) do
    tenant = RadioappWeb.get_tenant(conn)
    logs = Station.list_segments_for_date(params, tenant)

    csv =
      Builder.to_csv2(
        [
          :program_name,
          :host_name,
          :log_category,
          :date,
          :log_start_time,
          :log_end_time,
          :language,
          :start_time,
          :end_time,
          :artist,
          :song_title,
          :category,
          :category_name,
          :socan_type,
          :catalogue_number,
          :new_music,
          :local,
          :instrumental,
          :can_con,
          :hit,
          :indigenous_artist,
          :emerging_artist
        ],
        logs
      )
      |> Enum.join()


    conn
    |> send_download(
      {:binary, csv},
      content_type: "application/csv",
      disposition: :attachment,
      filename: "log-download.csv"
    )
  end

  def log_index(conn,  %{"log_id" => log_id}) do

    tenant = RadioappWeb.get_tenant(conn)
    current_user = conn.assigns.current_user
    log = Station.get_log!(log_id, tenant)
    segments = Station.list_segments_for_log(log, tenant)
    render(conn, "log.html", current_user: current_user, log: log, segments: segments)
  end


  def export_log(conn, %{"log_id" => log_id}) do
    tenant = RadioappWeb.get_tenant(conn)
    log = Station.get_log!(log_id, tenant)
    segments = Station.list_segments_for_log_export(log, tenant)
    csv =
      Builder.to_csv2(
        [
          # :start_datetime,
          # :end_datetime,
          # time would need to be *_datetime not *_time because you
          # can't convert to time in the select / allow import to import datetime
          :start_time,
          :end_time,
          :artist,
          :song_title,
          :category,
          :socan_type,
          :catalogue_number,
          :new_music,
          :local,
          :instrumental,
          :can_con,
          :hit,
          :indigenous_artist,
          :emerging_artist
        ],
        segments
      )
      |> Enum.join()


    conn
    |> send_download(
      {:binary, csv},
      content_type: "application/csv",
      disposition: :attachment,
      filename: "log-download.csv"
    )
  end

  def export_charts(conn, %{"search_params" => params}) do
    search = SearchParams.new(params)
    tenant = RadioappWeb.get_tenant(conn)
    applied = SearchParams.apply(search)
    charts = Station.list_charts_for_export(applied, applied.filter, tenant)
    csv =
      Builder.to_csv2(
        [
          :program_name,
          :host_name,
          :date,
          :artist,
          :song_title,
          :category,
          :new_music,
          :local,
          :count
        ],
        charts
      )
    |> Enum.join()


    filename = case applied.filter do
      "new_music" -> "charts-new-music.csv"
      "local" -> "charts-local.csv"
      _ -> "charts-all.csv"
    end

    conn
    |> send_download(
      {:binary, csv},
      content_type: "application/csv",
      disposition: :attachment,
      filename: filename
    )
  end




end

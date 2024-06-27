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
      |> cast(params, [:start_date, :end_date])
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
    # user_role = 
    #   if Map.get(current_user.roles, tenant) == nil do
    #     Map.get(current_user.roles, "admin")
    #   else 
    #     Map.get(current_user.roles, tenant)
    #   end
    user_role=Admin.get_user_role(current_user, tenant)
    dbg(user_role)
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
          :socan_type,
          :catalogue_number,
          :new_music,
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
end

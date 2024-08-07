defmodule RadioappWeb.PlayoutSegmentController do
  use RadioappWeb, :controller

  alias Radioapp.{Station, Admin}

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
      one_week_ago = Station.previous_week(today)
      
      changeset(
        %__MODULE__{
          start_date: one_week_ago,
          end_date: today
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
    user_role=Admin.get_user_role(current_user, tenant)
    %{timezone: timezone} = Admin.get_stationdefaults!(tenant)
    playout_segments =
      if search.valid? do
        Station.list_full_playout_segments(SearchParams.apply(search), tenant)
      else
        []
      end
    render(conn, "index.html", search: search, playout_segments: playout_segments, user_role: user_role, timezone: timezone)
  end

  def search(conn, %{"search_params" => params}) do
    search = SearchParams.new(params)
    tenant = RadioappWeb.get_tenant(conn)
    current_user = conn.assigns.current_user
    %{timezone: timezone} = Admin.get_stationdefaults!(tenant)

    
    playout_segments =
      if search.valid? do
        Station.list_full_playout_segments(SearchParams.apply(search), tenant)
      else
        []
      end
    user_role=Admin.get_user_role(current_user, tenant)

    render(conn, "index.html", search: search, playout_segments: playout_segments, user_role: user_role, timezone: timezone)
  end
end

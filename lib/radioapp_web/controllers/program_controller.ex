defmodule RadioappWeb.ProgramController do
  use RadioappWeb, :controller

  alias Radioapp.Station
  alias Radioapp.Station.{Program, Image}
  alias Radioapp.Admin

  defmodule SearchParams do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :select_filter, :string
    end

    def new(%{} = params) do
      sort_order = "all"

      changeset(
        %__MODULE__{
          select_filter: sort_order
        },
        params
      )
    end

    def changeset(search, %{} = params) do
      search
      |> cast(params, [:select_filter])
      |> validate_required([:select_filter])
    end

    def apply(search) do
      apply_changes(search)
    end
  end

  def index(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    programs = Station.list_programs(tenant)
    raw_programs = Station.list_all_programs(tenant)

    program_show = Admin.get_stationdefaults!(tenant).program_show

    current_user = conn.assigns.current_user
    role = if current_user != nil do
      Admin.get_user_role(current_user, tenant)
    else 
      nil
    end
    all_programs = 
      if current_user != nil do
        raw_programs
      else
        # if not logged in
        case program_show do
          "programs with timeslots" -> Station.list_programs_with_timeslot(raw_programs)
          "use hidden checkbox" -> Station.list_programs_not_hidden(raw_programs)
          _ -> raw_programs
        end   
      end
    search = SearchParams.new(%{})
    render(conn, :index, programs: programs, all_programs: all_programs, current_user: current_user, role: role, all_programs: all_programs, search: search)
  end

  def search(conn, %{"search_params" => params}) do
    search = SearchParams.new(params)
    tenant = RadioappWeb.get_tenant(conn)
    programs = Station.list_programs(tenant)
    raw_programs = Station.list_all_programs(tenant)
    current_user = conn.assigns.current_user
    role = if current_user != nil do
      Admin.get_user_role(current_user, tenant)
    else 
      nil
    end

    all_programs = 
      if search.valid? do
        
        Station.select_programs(SearchParams.apply(search), raw_programs, tenant)
      else
        []
      end
    render(conn, :index, programs: programs, all_programs: all_programs, current_user: current_user, role: role, all_programs: all_programs, search: search)
  end

  def new(conn, _params) do
    tenant = RadioappWeb.get_tenant(conn)
    changeset = Station.change_program(%Program{})
    list_links = [{"", nil} | Admin.list_links_dropdown(tenant)]
    render(conn, :new, changeset: changeset, list_links: list_links)
  end

  def create(conn, %{"program" => program_params}) do
    tenant = RadioappWeb.get_tenant(conn)

    case Station.create_program(program_params, tenant) do
      {:ok, program} ->
        conn
        |> put_flash(:info, "Program created successfully.")
        |> redirect(to: ~p"/programs/#{program}")

      {:error, %Ecto.Changeset{} = changeset} ->
        list_links = Admin.list_links_dropdown(tenant)
        render(conn, :new, changeset: changeset, list_links: list_links)
    end
  end

  def show(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    program = Station.get_program!(id, tenant)
    timeslots = Station.list_timeslots_for_program(program, tenant)
    stationdefaults = Admin.get_stationdefaults!(tenant)
    enable_archives = stationdefaults.enable_archives
    {list_timeslots} = case enable_archives do
      "enabled" -> Station.list_timeslots_for_archives(program, tenant)
      "log based" -> Station.list_timeslots_for_archives_from_logs(program, tenant)
      "none" -> {[]}
    end

    image =
    case program.images do
      %Image{} = image ->
        image
        |> Image.changeset(%{})

      nil ->
        %Image{}
        |> Image.changeset(%{})
    end
    user = conn.assigns.current_user

    cols = case program.images do
      nil -> if user do "md:w-1/2" else "w-full" end
      _ -> "md:w-1/2"
    end
    
    user_role = if user != nil do
      
      case Map.get(user.roles, tenant) do
        nil -> Map.get(user.roles, "admin")
        _ -> Map.get(user.roles, tenant)
      end
    end

    render(conn, :show, timeslots: timeslots, program: program, image: image, user_role: user_role, cols: cols, list_timeslots: list_timeslots, enable_archives: enable_archives)
  end

  def edit(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    program = Station.get_program!(id, tenant)
    list_links = [{"", nil} | Admin.list_links_dropdown(tenant)]
    changeset = Station.change_program(program)
    render(conn, :edit, program: program, changeset: changeset, list_links: list_links)
  end

  def update(conn, %{"id" => id, "program" => program_params}) do
    tenant = RadioappWeb.get_tenant(conn)
    program = Station.get_program!(id, tenant)

    case Station.update_program(program, program_params) do
      {:ok, program} ->
        conn
        |> put_flash(:info, "Program updated successfully.")
        |> redirect(to: ~p"/programs/#{program}")

      {:error, %Ecto.Changeset{} = changeset} ->
        list_links = Admin.list_links_dropdown(tenant)
        render(conn, :edit, program: program, changeset: changeset, list_links: list_links)
    end
  end

  def delete(conn, %{"id" => id}) do
    tenant = RadioappWeb.get_tenant(conn)
    program = Station.get_program!(id, tenant)
    {:ok, _program} = Station.delete_program(program)

    conn
    |> put_flash(:info, "Program deleted successfully.")
    |> redirect(to: ~p"/programs")
  end
end

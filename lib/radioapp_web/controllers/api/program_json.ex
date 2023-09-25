defmodule RadioappWeb.Api.ProgramApiJSON do
  alias Radioapp.Station.Program
  alias Radioapp.Station

  @doc """
  Renders a list of programs.
  """
  def index(%{programs: programs}) do
    %{data: for(program <- programs, do: data(program))}
  end

  @doc """
  Renders the current program.
  """
  def show(%{conn: conn}) do
    tenant = conn.assigns.tenant
    now = DateTime.to_naive(Timex.now("America/Toronto"))
    time_now = DateTime.to_time(Timex.now("America/Toronto"))
    weekday = Timex.weekday(now)

    show_name = Station.get_program_from_time(weekday, time_now, tenant)
    %{data: %{
      current: show_name
    }}
  end

  defp data(%Program{} = program) do
    %{
      id: program.id,
      name: program.name
      # starttime: program.starttime
    }
  end
end

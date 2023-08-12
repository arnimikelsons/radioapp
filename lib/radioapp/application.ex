defmodule Radioapp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RadioappWeb.Telemetry,
      # Start the Ecto repository
      Radioapp.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Radioapp.PubSub},
      # Start Finch
      {Finch, name: Radioapp.Finch},
      # Start the Endpoint (http/https)
      RadioappWeb.Endpoint
      # Start a worker by calling: Radioapp.Worker.start_link(arg)
      # {app.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Radioapp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RadioappWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

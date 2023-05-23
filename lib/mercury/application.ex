defmodule Mercury.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MercuryWeb.Telemetry,
      # Start the Ecto repository
      Mercury.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Mercury.PubSub},
      # Start Finch
      {Finch, name: Mercury.Finch},
      # Start the Endpoint (http/https)
      MercuryWeb.Endpoint
      # Start a worker by calling: Mercury.Worker.start_link(arg)
      # {Mercury.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mercury.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MercuryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

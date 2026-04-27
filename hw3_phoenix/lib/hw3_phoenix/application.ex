defmodule Hw3Phoenix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Hw3PhoenixWeb.Telemetry,
      Hw3Phoenix.Repo,
      {DNSCluster, query: Application.get_env(:hw3_phoenix, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Hw3Phoenix.PubSub},
      # Start a worker by calling: Hw3Phoenix.Worker.start_link(arg)
      # {Hw3Phoenix.Worker, arg},
      # Start to serve requests, typically the last entry
      Hw3PhoenixWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hw3Phoenix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Hw3PhoenixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

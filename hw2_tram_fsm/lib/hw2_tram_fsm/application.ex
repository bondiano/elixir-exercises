defmodule Hw2TramFsm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Hw2TramFsm.Worker.start_link(arg)
      # {Hw2TramFsm.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hw2TramFsm.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

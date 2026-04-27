defmodule Hw3Phoenix.DataCase do
  @moduledoc """
  Базовый case для тестов, работающих с Ecto Repo через Sandbox.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Hw3Phoenix.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Hw3Phoenix.DataCase
    end
  end

  setup tags do
    Hw3Phoenix.DataCase.setup_sandbox(tags)
    :ok
  end

  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Hw3Phoenix.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end
end

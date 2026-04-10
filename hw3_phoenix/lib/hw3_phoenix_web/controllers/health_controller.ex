defmodule Hw3PhoenixWeb.HealthController do
  use Hw3PhoenixWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "ok"})
  end
end

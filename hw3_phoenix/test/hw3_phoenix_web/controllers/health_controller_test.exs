defmodule Hw3PhoenixWeb.HealthControllerTest do
  use Hw3PhoenixWeb.ConnCase

  test "GET /api/health returns ok status", %{conn: conn} do
    conn = get(conn, ~p"/api/health")

    assert json_response(conn, 200) == %{"status" => "ok"}
  end

  test "GET /api/health returns json content type", %{conn: conn} do
    conn = get(conn, ~p"/api/health")

    assert get_resp_header(conn, "content-type") |> hd() =~ "application/json"
  end
end

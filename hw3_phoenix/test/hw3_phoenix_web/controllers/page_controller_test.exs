defmodule Hw3PhoenixWeb.PageControllerTest do
  use Hw3PhoenixWeb.ConnCase

  test "GET / returns 200", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end

  test "GET / returns html content type", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert get_resp_header(conn, "content-type") |> hd() =~ "text/html"
  end

  test "GET /nonexistent returns 404", %{conn: conn} do
    conn = get(conn, "/nonexistent")
    assert conn.status == 404
  end
end

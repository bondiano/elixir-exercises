defmodule Hw3PhoenixWeb.ErrorJSONTest do
  use Hw3PhoenixWeb.ConnCase, async: true

  test "renders 404" do
    assert Hw3PhoenixWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Hw3PhoenixWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end

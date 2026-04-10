defmodule Hw3PhoenixWeb.PageController do
  use Hw3PhoenixWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

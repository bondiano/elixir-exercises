defmodule Hw3PhoenixWeb.Router do
  use Hw3PhoenixWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Hw3PhoenixWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Hw3PhoenixWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", Hw3PhoenixWeb do
    pipe_through :api

    get "/health", HealthController, :index
  end
end

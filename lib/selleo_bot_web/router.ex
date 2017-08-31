defmodule SelleoBotWeb.Router do
  use SelleoBotWeb, :router

  pipeline :browser do
    # plug :accepts, ["html"]
    # plug :fetch_session
    # plug :fetch_flash
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    # plug :accepts, ["json"]
  end

  scope "/", SelleoBotWeb do
    pipe_through :browser # Use the default browser stack

    get "/", HomeController, :index
  end

  scope "/api", SelleoBotApi do
    pipe_through :api

    post "/slack/cmd", CommandController, :create
  end
end

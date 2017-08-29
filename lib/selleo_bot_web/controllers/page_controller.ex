defmodule SelleoBotWeb.PageController do
  use SelleoBotWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

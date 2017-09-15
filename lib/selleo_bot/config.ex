defmodule SelleoBot.Config do

  def all do
    Application.get_env(:selleo_bot, SelleoBotWeb.Endpoint)
  end

  def get(key) do
    all()[key]
  end

end

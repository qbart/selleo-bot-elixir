defmodule SelleoBotApi.CommandController do
  use SelleoBotWeb, :controller
  alias SelleoBotApi.{LogTimeHandler}

  def create(
    conn,
    %{
      "response_url" => response_url,
      "text"         => text,
      "user_id"      => user_id
    }
  ) do
    case get_handler(text) do
      {:ok, handler, params} ->
        msg = handler.handle(params, user_id, response_url)
        # say(conn, "Processing you request. Please wait.")
        say(conn, msg)

      {:not_found} ->
        say(conn, "Command not found")
    end

  end

  defp get_handler(text) do
    case text do
      "logtime " <> params -> {:ok, LogTimeHandler, params}
      _                    -> {:not_found}
    end
  end

  defp say(conn, text) do
    conn
      |> put_resp_content_type("text/plain")
      |> send_resp(:ok, text)
  end

end

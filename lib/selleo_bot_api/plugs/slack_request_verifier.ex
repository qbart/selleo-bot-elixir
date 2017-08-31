defmodule SelleoBotApi.SlackRequestVerifier do
  import Plug.Conn, only: [ send_resp: 3, halt: 1 ]

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    cmd     = get_config(:slack_command)
    domain  = get_config(:slack_team_domain)
    team_id = get_config(:slack_team_id)
    token   = get_config(:slack_bot_token)

    case conn.params do

      %{
        "command"      => ^cmd,
        "response_url" => _,
        "team_domain"  => ^domain,
        "team_id"      => ^team_id,
        "token"        => ^token,
        "user_id"      => _
      } ->
        conn

      _ ->
        conn
          |> send_resp(401, "Unauthorized")
          |> halt()

    end
  end

  defp get_config(key) do
    Application.get_env(:selleo_bot, SelleoBotWeb.Endpoint)[key]
  end

end

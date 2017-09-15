defmodule SelleoBotApi.SlackRequestVerifier do
  import Plug.Conn, only: [ send_resp: 3, halt: 1 ]

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    config  = Application.get_env(:selleo_bot, SelleoBotWeb.Endpoint)
    cmd     = config[:slack_command]
    domain  = config[:slack_team_domain]
    team_id = config[:slack_team_id]
    token   = config[:slack_bot_token]

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

end

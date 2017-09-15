defmodule SelleoBotApi.Apis.Slack do
  alias SelleoBot.Config;

  @base_url "https://slack.com/api/"
  @json_headers [{"Content-type", "application/json"}]

  defmodule User do
    @enforce_keys [:id, :email]
    defstruct [:id, :email]
  end

  def find_user(id) do
    {:ok, resp} = get("users.profile.get", %{"user" => id})
    {:ok, body} = Poison.Parser.parse(resp.body)

    case body["ok"] do
      true  -> {:ok, %User{id: id, email: body["profile"]["email"]} }
      false -> {:error, "Slack API: Cannot get user email (#{body["error"]})"}
    end
  end

  def post_response(url, title, text, color) do
    body = Poison.encode!(%{
      "attachments" => [%{
        "title" => title,
        "text" => text,
        "color" => to_string(color)
      }]
    })

    HTTPoison.post(url, body, @json_headers, [ ssl: [{:versions, [:'tlsv1.2']}] ])
  end

  defp get(method, params) do
    token = Config.get(:slack_access_token)
    params = params |> Map.put("token", token)
    HTTPoison.get(@base_url <> method <> "?" <> URI.encode_query(params), [], [ ssl: [{:versions, [:'tlsv1.2']}] ])
  end

end

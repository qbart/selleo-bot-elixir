defmodule SelleoBotApi.Apis.Dm do
  alias SelleoBot.Config;

  @client_id "6V5nxpWkZd7puFmC"
  @client_secret "5mqrNpAq5kf7pDANY4pDB3KW3B2JBqJaGBspvkwB68YXaqwvQzmJBcz2gLeXdvPWjb5z3SNsCKYz8jXzqzkWvcJZqdpSMf6Ub9Sznv59gum7d7AMBQQ4kq9qNLBBQGXy"
  @url "http://localhost:3000/api/manage/v1/time_entries"

  defmodule Error do
    defstruct [:title, :details]
  end

  def create_time_entries(email, time_entries) do
    body = Poison.encode!(%{
      "entries" => time_entries
    })
    headers = build_headers(email, body)

    {:ok, response} = HTTPoison.post(@url, body, headers, [])
    case response.status_code do
      201 -> {:ok, "Test"}
      200 -> {:ok, "Test"}
      _   -> {:error, parse_json_errors(response.body)}
    end
  end


  defp build_headers(email, body) do
    %{
      "Authorization" => "DM3 client_id=#{@client_id};user=#{email};signature=#{signature(body)}",
      "Content-type" => "application/json"
    }
  end

  defp signature(body) do
    checksum = :crypto.hash(:md5, body) |> Base.encode16(case: :lower)
    :crypto.hmac(:sha256, @client_secret, checksum) |> Base.encode64
  end

  defp parse_json_errors(body) do
    %{"errors" => [%{"title" => title, "detail" => details}]} = Poison.Parser.parse!(body)
    %Error{title: title, details: details}
  end

end

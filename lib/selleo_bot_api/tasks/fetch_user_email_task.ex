defmodule SelleoBotApi.FetchUserEmailTask do
  alias SelleoBotApi.Apis

  def run(user_id) do
    Apis.Slack.find_user(user_id)
  end
end

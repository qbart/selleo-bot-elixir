defmodule SelleoBotApi.LogTimeHandler do
  alias SelleoBotApi.{Scheduler, Apis, FetchUserEmailTask, ParseInputTask}

  def handle(params, user_id, response_url) do
    queue = Scheduler.queue(
      fetcher: fn -> FetchUserEmailTask.run(user_id) end,
      parser: fn -> ParseInputTask.run(params) end
    )

    case Scheduler.await queue do
      {:ok, [fetcher: user, parser: entries] } -> logtime(user, entries, response_url)
      {:error, errors}                         -> respond_with_errors(errors, response_url)
    end
  end

  defp respond_with_errors(errors, response_url) do
    Apis.Slack.post_response(response_url, "Something went wrong", Enum.join(errors, "\n"), :danger)
  end

  defp logtime(user, entries, response_url) do
    result = Apis.Dm.create_time_entries(user.email, entries)
    case result do
      {:ok, response} -> Apis.Slack.post_response(response_url, "[WORK IN PROGRESS] #{user.email}", response, :good)
      {:error, error} -> Apis.Slack.post_response(response_url, "Error: #{error.title}", error.details, :danger)
    end
  end

end

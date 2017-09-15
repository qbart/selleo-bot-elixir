defmodule SelleoBotApi.LogTimeHandler do
  alias SelleoBotApi.Scheduler
  alias SelleoBotApi.Apis

  defmodule ParseInputTask do
    alias SelleoBotApi.TimeEntry

    def run(params) do
      result = parse_time_entries(params)

      case validate(result, params) do
        {:ok, entries} ->
          {
            :ok,
            entries
            |> Enum.map( &to_string(&1) )
            |> Enum.join("\n")
          }

        {:error, msg} -> {:error, msg}
      end
    end

    defp validate(entries, params) do
      valid = Enum.all? entries, fn(entry) ->
        entry != nil
      end

      if valid do
        {:ok, entries}
      else
        {:error, "Parsing error:\n#{params}"}
      end
    end

    defp parse_time_entries(params) do
      params
      |> String.split(~r{\r?\n}, trim: true)
      |> build_time_entries
    end

    defp build_time_entries([head | tail]) do
      case TimeEntry.parse(head) do
        {:ok   , entry} -> [ entry | build_time_entries(tail) ]
        {:error, _}     -> [ nil   | build_time_entries(tail) ]
      end
    end

    defp build_time_entries([]), do: []
  end


  defmodule FetchUserEmailTask do
    alias SelleoBotApi.Apis

    def run(user_id) do
      Apis.Slack.find_user(user_id)
    end
  end

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
    Apis.Slack.post_response(response_url, "[WORK IN PROGRESS] #{user.email}", entries, :good)
  end

end

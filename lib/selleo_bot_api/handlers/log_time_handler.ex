defmodule SelleoBotApi.LogTimeHandler do
  alias SelleoBotApi.TimeEntry

  def handle(params, user_id, response_url) do
    result = parse_time_entries(params)

    case validate(result) do
      {:ok, entries} ->
        entries
        |> Enum.map( &to_string(&1) )
        |> Enum.join("\n")

      {:error, msg} -> msg
    end
  end

  defp validate(entries) do
    valid = Enum.all? entries, fn(entry) ->
      entry != nil
    end

    if valid do
      {:ok, entries}
    else
      {:error, "Parsing error"}
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

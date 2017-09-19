defmodule SelleoBotApi.ParseInputTask do
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


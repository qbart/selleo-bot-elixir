defmodule SelleoBotApi.TimeEntry do
  @enforce_keys [:date, :start_time, :end_time, :details]
  defstruct [:date, :start_time, :end_time, :details]

  @regex ~r/
    \A
    (?<date>\d{4}-\d{2}-\d{2})
    \s+
    (?<start_time>\d{2}:\d{2})
    \s+
    (?<end_time>\d{2}:\d{2})
    \s+
    (?<details>.+)
    \z
  /x

  @doc """
  Parse time entry into structure.

      iex> SelleoBotApi.TimeEntry.parse("2017-08-31 09:00 17:00 task-1 hello")
      {:ok, %SelleoBotApi.TimeEntry{ date: "2017-08-31", start_time: "09:00", end_time: "17:00", details: "task-1 hello" }}
  """
  def parse(str) do
    cond do
      String.match?(str, @regex) -> {:ok   , @regex |> Regex.named_captures(str) |> build()}
      true                       -> {:error, "No match"}
    end
  end

  defp build(%{"date" => date, "start_time" => start_time, "end_time" => end_time, "details" => details}) do
    %SelleoBotApi.TimeEntry{
      date:       date,
      start_time: start_time,
      end_time:   end_time,
      details:    details
    }
  end

end

defimpl String.Chars, for: SelleoBotApi.TimeEntry do
  def to_string(entry) do
    "#{entry.date} #{entry.start_time} #{entry.end_time} #{entry.details}"
  end
end

defmodule SelleoBotApi.Scheduler do

  def queue(list) do
    Enum.map list, fn {key, func} ->
      {key, Task.async(func)}
    end
  end

  def await(list) do
    task_results = Enum.map list, fn {key, task} ->
      {status, result} = Task.await(task)
      {status, {key, result}}
    end

    results = Enum.group_by task_results, fn {status, _} ->
      status
    end

    case results do
      %{:error => invalid} ->
        {:error, Enum.map(invalid, fn {_, {_, msg}} -> msg end)}

      %{:ok => valid} ->
        {:ok, Enum.map(valid, fn {_, item} -> item end)}
    end
  end

end

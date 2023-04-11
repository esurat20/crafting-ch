defmodule CodingChalledge do
  @moduledoc """
    Current module takes body with tasks list and order these tasks
    according to `requires` field in task object.

    The module does not suppose to solve logic issues of tasks dependence
    and can go run infinity cycle if tasks have cycling dependencies.
    It can be fixed by some improvements of this code. Not sure that chanlledge
    requires it.

    I had some doubts about additional part where I need to return bash script.
    So as you can see I just create string with commands separated by new line character.

    Also it does not clear about phoenix app with (router, controller and so on). 
    Can be added on demand.

    Starting sequence:

    1. Run interactive elixir shell by 'iex'
    2. Compile provided file by 'c("coding_challenge.ex")'
    3. Run `perform_sorting` method to get body with ordered list of tasks.

       Command 'CodingChalledge.perform_sorting'

    4. Run `compose_script` method to get string with bash commands.

       Command 'CodingChalledge.compose_script'

    PS: Script uses predefined request body which I presented as elixir Map, becasuse
    usually if you use Phoenix decoding of request body goes under hood and you get body
    as Map instead of raw json.

    You are able to put your own body (presented as Map).

    This solution does not pretend to be optimal (on the best performance). It just solves the
    coding challenge task. I think it requires to do more measurements if there is supposed to 
    have a really big body with thousands of tasks. 
  """

  @default_request_body %{
    "tasks" => [
      %{
        "name" => "task-1",
        "command" => "touch /tmp/file1"
      },
      %{
        "name" => "task-2",
        "command" => "cat /tmp/file1",
        "requires" => [
          "task-3"
        ]
      },
      %{
        "name" => "task-3",
        "command" => "echo 'Hello World!' > /tmp/file1",
        "requires" => [
          "task-1"
        ]
      },
      %{
        "name" => "task-4",
        "command" => "rm /tmp/file1",
        "requires" => [
          "task-2",
          "task-3"
        ]
      }
    ]
  }

  def perform_sorting(body \\ @default_request_body) do
    sorted_tasks = sort_tasks(body["tasks"])

    %{"tasks" => sorted_tasks}
  end

  def compose_script(body \\ @default_request_body) do
    body["tasks"]
    |> sort_tasks()
    |> Enum.map(& &1["command"])
    |> List.insert_at(0, "#!/usr/bin/env bash")
    |> Enum.join("\n")
  end

  defp sort_tasks(tasks) when is_list(tasks) do
    tasks
    |> sort_tasks([])
    |> Enum.reverse()
  end

  defp sort_tasks(_), do: raise("Wrong body was provided")

  defp sort_tasks([task | tasks], sorted_tasks) do
    requires = Map.get(task, "requires", [])

    if Enum.empty?(requires) do
      sort_tasks(tasks, [task | sorted_tasks])
    else
      sortered_task_names = Enum.map(sorted_tasks, & &1["name"])

      if Enum.all?(requires, &(&1 in sortered_task_names)) do
        sort_tasks(tasks, [task | sorted_tasks])
      else
        tasks
        |> List.insert_at(-1, task)
        |> sort_tasks(sorted_tasks)
      end
    end
  end

  defp sort_tasks([], sorted_tasks) do
    sorted_tasks
  end
end

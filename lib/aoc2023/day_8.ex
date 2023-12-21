defmodule Aoc2023.Day8 do
  alias Aoc2023.Day8.{
    Agent
  }

  @doc """
  First line is a series of Rs and Ls, indicating instructions per line of whether
  you should choose the left or right element of the tuple on the current line.

  We start at AAA and follow the RL instructions until we reach ZZZ. Return the
  number of steps it took to get there.

  Strategy:
  I think I should be able to use Stream.iterate/1 to do this. I could pass the parsed
  values around, but it's also easy to create an agent to take care of holding that
  data in memory, and it gives us a nice separation of concerns.

  iex> Aoc2023.Day8.part_1(:test1)
  2

  iex> Aoc2023.Day8.part_1(:test2)
  6

  iex> Aoc2023.Day8.part_1(:real)
  18113

  """
  def part_1(input_type) do
    {:ok, _agent} = Agent.start_link(input_type: input_type)

    {"AAA", 0}
    |> Stream.iterate(&get_next_node/1)
    |> Enum.take_while(fn {val, _} -> val != "ZZZ" end)
    |> Enum.count()
  end

  defp get_next_node({key, idx}) do
    {left, right} = Agent.get_node(key)

    case Agent.get_instruction(idx) do
      {:L, next_idx} -> {left, next_idx}
      {:R, next_idx} -> {right, next_idx}
    end
  end
end

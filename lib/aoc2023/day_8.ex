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
    {:ok, agent} = Agent.start_link(input_type: input_type)

    get_steps_count("AAA", agent, fn {val, _} -> val != "ZZZ" end)
  end

  @doc """
  The instructions have changed - we want to simultaneously start at any node that
  ends in A, and follow the instructions until they all simultaneously land on a
  node that ends in Z.

  I suppose I cheated a bit by not actually writing the algorithm to find the least
  common multiple.

  iex> Aoc2023.Day8.part_2(:test3)
  6

  iex> Aoc2023.Day8.part_2(:real)
  12315788159977
  """
  def part_2(input_type) do
    {:ok, agent} = Agent.start_link(input_type: input_type)
    get_lcm(agent)
  end

  defp get_lcm(agent) do
    agent
    |> Agent.get_A_keys()
    |> Enum.map(fn key -> get_steps_count(key, agent, &doesnt_end_in_z?/1) end)
    |> Enum.reduce(nil, &_get_lcm/2)
  end

  defp doesnt_end_in_z?({<<_::binary-size(1), _::binary-size(1), "Z">>, _}), do: false

  defp doesnt_end_in_z?({<<_::binary-size(1), _::binary-size(1), _::binary-size(1)>>, _}),
    do: true

  defp _get_lcm(left, nil) do
    left
  end

  defp _get_lcm(left, right) when is_integer(right) do
    Math.lcm(left, right)
  end

  def get_steps_count(start, agent, cont_fn) do
    {start, 0}
    |> Stream.iterate(&get_next_node(&1, agent))
    |> Enum.take_while(cont_fn)
    |> Enum.count()
  end

  defp get_next_node({key, idx}, agent) when is_binary(key) do
    {left, right} = Agent.get_node(agent, key)

    case Agent.get_instruction(agent, idx) do
      {:L, next_idx} -> {left, next_idx}
      {:R, next_idx} -> {right, next_idx}
    end
  end
end

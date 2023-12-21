defmodule Aoc2023.Day7 do
  alias __MODULE__.{
    Hand,
    Parser
  }

  @doc """
  Part 1

  I'm getting lazy about copying the instructions. Hopefully the
  naming and comments make it clear what's happening here.

  iex> Aoc2023.Day7.part_1(:test)
  6440

  iex> Aoc2023.Day7.part_1(:real)
  252656917
  """
  def part_1(input_type) do
    input_type
    |> parse_hands()
    |> rank_cards()
    |> Enum.map(&calculate_score/1)
    |> Enum.reduce(0, &Kernel.+/2)
  end

  @doc """
  Part 2

  This time, Js are jokers. They can change the hand type, but
  their actual value is always low.

  iex> Aoc2023.Day7.part_2(:test)
  5905

  iex> Aoc2023.Day7.part_2(:real)
  253499763
  """
  def part_2(input_type) do
    input_type
    |> parse_hands(true)
    |> rank_cards()
    |> Enum.map(&calculate_score/1)
    |> Enum.reduce(0, &Kernel.+/2)
  end

  def parse_hands(input_type, jokers_wild? \\ false) do
    __MODULE__
    |> Aoc2023.read_input_file(input_type)
    |> Stream.map(&Parser.parse_hand(&1, jokers_wild?))
  end

  def rank_cards(stream) do
    stream
    |> Enum.sort(&sort_cards/2)
    |> Enum.with_index(1)
    |> Enum.map(&add_rank/1)
  end

  defp calculate_score(%{} = card) do
    card.bid * card.rank
  end

  defp add_rank({card, rank}), do: Map.put(card, :rank, rank)

  defp sort_cards(%{type: type, value: value1}, %{type: type, value: value2}) do
    value1 < value2
  end

  defp sort_cards(%{type: type1}, %{type: type2}) do
    Hand.rank(type1) < Hand.rank(type2)
  end
end

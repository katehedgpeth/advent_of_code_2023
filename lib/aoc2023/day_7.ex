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

  def parse_hands(input_type) do
    __MODULE__
    |> Aoc2023.read_input_file(input_type)
    |> Stream.map(&Parser.parse_hand/1)
  end

  def rank_cards(stream) do
    stream
    |> Enum.group_by(&Hand.rank(&1.type))
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.flat_map(&sort_by_card_value/1)
    |> Enum.with_index(1)
    |> Enum.map(&add_rank/1)
  end

  defp sort_by_card_value({_, cards}) do
    Enum.sort(cards, &card_sorter/2)
  end

  defp card_sorter(%{hand: hand1}, %{hand: hand2}) do
    Hand.higher_hand(hand1, hand2)
  end

  defp calculate_score(%{} = card) do
    card.bid * card.rank
  end

  defp add_rank({card, rank}), do: Map.put(card, :rank, rank)
end

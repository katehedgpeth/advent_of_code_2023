defmodule Aoc2023.Day4 do
  @moduledoc """
  Day 4
  """

  @doc """
  Part 1

  ```
  Each card has two lists of numbers separated by a vertical bar (|):
  a list of winning numbers and then a list of numbers you have. You
  organize the information into a table (your puzzle input).

  As far as the Elf has been able to figure out, you have to figure out
  which of the numbers you have appear in the list of winning numbers.
  The first match makes the card worth one point and each match after the
  first doubles the point value of that card.

  How many points are all cards worth in total?
  ```

  Strategy:
  MapSets make this dead simple to figure out -- assuming that numbers
  can't be repeated. The instructions don't specify, but my answer was
  accepted so... moving on!


  iex> Aoc2023.Day4.part_1(:test)
  13

  iex> Aoc2023.Day4.part_1(:real)
  26346
  """
  def part_1(input_type) do
    __MODULE__
    |> Aoc2023.read_input_file(input_type)
    |> Stream.map(&parse_card/1)
    |> Stream.map(&calculate_card_value/1)
    |> Enum.reduce(0, &Kernel.+/2)
  end

  defp parse_card("Card " <> card) do
    [_, card] = String.split(card, ~r/\d+:/)

    [winners, numbers] =
      card
      |> String.split(" | ")
      |> Enum.map(&parse_number_set/1)

    winners
    |> MapSet.intersection(numbers)
    |> Enum.into([])
  end

  defp parse_number_set("" <> numbers) do
    numbers
    |> String.trim()
    |> String.split(~r/\s+/)
    |> Enum.map(&String.to_integer/1)
    |> MapSet.new()
  end

  defp calculate_card_value([]),
    do: 0

  defp calculate_card_value([_]),
    do: 1

  defp calculate_card_value([_ | rest]),
    do: Integer.pow(2, length(rest))
end

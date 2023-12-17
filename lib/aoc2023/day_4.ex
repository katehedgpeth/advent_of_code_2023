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

  @doc """
  Part 2

  ```
  There's no such thing as "points". Instead, scratchcards only
  cause you to win more scratchcards equal to the number of winning
  numbers you have.

  Specifically, you win copies of the scratchcards below the winning
  card equal to the number of matches. So, if card 10 were to have 5
  matching numbers, you would win one copy each of cards 11, 12, 13,
  14, and 15.

  Copies of scratchcards are scored like normal scratchcards and have
  the same card number as the card they copied. So, if you win a copy
  of card 10 and it has 5 matching numbers, it would then win a copy
  of the same cards that the original card 10 won: cards 11, 12, 13, 14,
  and 15. This process repeats until none of the copies cause you to win
  any more cards. (Cards will never make you copy a card past the end of
  the table.)

  How many total scratchcards do you end up with?
  ```

  Strategy:
  Use the same functions as part 1 to count winners, but update it to also
  return the card's id. Create a map to store counts of how many copies
  exist of each card. Sort the IDs and iterate over them. For each ID, we
  do a double recursion - for each copy of the id, we recurse over the
  winners count and update the copy count of the child copies of that card.
  (I'm not sure if that description makes sense - my brain isn't working at
  full speed this afternoon)

  iex> Aoc2023.Day4.part_2(:test)
  30

  iex> Aoc2023.Day4.part_2(:real)
  8467762
  """
  def part_2(input) do
    counts =
      __MODULE__
      |> Aoc2023.read_input_file(input)
      |> Stream.map(&parse_card/1)
      |> Stream.map(&init_copies_acc/1)
      |> Enum.into(%{})

    counts
    |> Map.keys()
    |> Enum.sort()
    |> Enum.reduce(counts, &make_child_copies/2)
    |> Enum.reduce(0, &add_copies/2)
  end

  defp add_copies({_id, %{copies: copies}}, acc) do
    acc + copies
  end

  defp init_copies_acc({id, winners}) do
    {id, %{winners: winners, copies: 1}}
  end

  defp make_child_copies(id, acc) do
    acc
    |> Map.fetch!(id)
    |> Map.fetch!(:copies)
    |> update_copy_counts(id, acc)
  end

  defp update_copy_counts(0, _id, acc) do
    acc
  end

  defp update_copy_counts(count, id, acc) do
    acc
    |> Map.fetch!(id)
    |> Map.fetch!(:winners)
    |> length()
    |> Kernel.+(id)
    |> do_update_copy_counts(id, acc, count)
  end

  defp do_update_copy_counts(id, parent_id, acc, count) when parent_id == id do
    update_copy_counts(count - 1, id, acc)
  end

  defp do_update_copy_counts(id, parent_id, acc, count) do
    do_update_copy_counts(
      id - 1,
      parent_id,
      Map.update!(acc, id, &%{&1 | copies: &1.copies + 1}),
      count
    )
  end

  defp parse_card("Card " <> card) do
    [id, card] =
      card
      |> String.split(":")
      |> Enum.map(&String.trim/1)

    [winners, numbers] =
      card
      |> String.split(" | ")
      |> Enum.map(&parse_number_set/1)

    {String.to_integer(id),
     winners
     |> MapSet.intersection(numbers)
     |> Enum.into([])}
  end

  defp parse_number_set("" <> numbers) do
    numbers
    |> String.trim()
    |> String.split(~r/\s/)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
    |> MapSet.new()
  end

  defp calculate_card_value({_, []}),
    do: 0

  defp calculate_card_value({_, [_]}),
    do: 1

  defp calculate_card_value({_, [_ | rest]}),
    do: Integer.pow(2, length(rest))
end

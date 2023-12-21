defmodule Aoc2023.Day6 do
  alias Aoc2023.Day6.WaysOfWinning
  alias Aoc2023.Day6.Parser

  @doc """
  Part 1

  ```
  Time:      7  15   30
  Distance:  9  40  200

  This document describes three races:

  The first race lasts 7 ms. The record distance in this race is 9 mm.
  The second race lasts 15 ms. The record distance in this race is 40 mm.
  The third race lasts 30 ms. The record distance in this race is 200 mm.

  Your toy boat has a starting speed of zero millimeters per millisecond.
  For each whole millisecond you spend at the beginning of the race holding
  down the button, the boat's speed increases by one millimeter per millisecond.

  To see how much margin of error you have, determine the number of ways you
  can beat the record in each race; in this example, if you multiply these
  values together, you get 288 (4 * 8 * 9).
  ```

  Strategy:
  Well, this is a goddamned cakewalk compared to the previous day. For part
  1 it seems fine to just brute-force calculate every possible time. If I need
  to optimize this for part 2 (which I'm sure I will), I'll probably refactor
  to create a range by finding the first time on each end that beats the distance.

  iex> Aoc2023.Day6.part_1(:test)
  288

  iex> Aoc2023.Day6.part_1(:real)
  500346
  """
  def part_1(input_type) do
    input_type
    |> Parser.parse_file(:part_1)
    |> Enum.map(&WaysOfWinning.calculate(&1, :brute_force))
    |> Enum.reduce(1, &Kernel.*/2)
  end

  @doc """
  Part 2

  ```
  As the race is about to start, you realize the piece of paper with race times
  and record distances you got earlier actually just has very bad kerning. There's
  really only one race - ignore the spaces between the numbers on each line.
  ```

  As expected. I wound up needing to also use binary search on both the high and low
  search to find the range without timing out. I refactored the BinarySearch module
  from the previous day and made it univerally available, since I'm sure I'm going
  to need it again.

  Even though Day 5 was very painful, I clearly learned something from that pain!

  iex> Aoc2023.Day6.part_2(:test)
  71503

  iex> Aoc2023.Day6.part_2(:real)
  42515755
  """

  def part_2(input_type) do
    input_type
    |> Parser.parse_file(:part_2)
    |> Enum.map(&WaysOfWinning.calculate(&1, :optimized))
    |> Enum.reduce(1, &Kernel.*/2)
  end
end

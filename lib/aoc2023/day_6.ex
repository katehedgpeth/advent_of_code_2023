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
    |> Parser.parse_file()
    |> Enum.map(&WaysOfWinning.calculate/1)
    |> Enum.reduce(1, &Kernel.*/2)
  end
end

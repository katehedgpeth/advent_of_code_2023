defmodule Aoc2023.Day3 do
  require Logger

  alias __MODULE__.{
    Matrix,
    Number,
    Symbol
  }

  @moduledoc """
  Day 3

  """

  @doc """
  Part 1

  ```
  The engine schematic (your puzzle input) consists of a visual representation
  of the engine. There are lots of numbers and symbols you don't really
  understand, but apparently any number adjacent to a symbol, even diagonally,
  is a "part number" and should be included in your sum. (Periods (.) do not
  count as a symbol.)

  What is the sum of all of the part numbers in the engine schematic?
  ```

  Strategy:
  1. For each line, identify all numbers and their index ranges, and all
      symbols. Save the range of each number.
  2. Create a map of every coord that contains a number.
  3. For each symbol, check every adjacent coordinate to see if it includes
      a number. If so, save that number to a MapSet (since the number may be
      adjacent to the symbol at multiple coordinates).

  4. Reduce the mapsets and add the numbers.

  This solution is definitely not elegant - I'm sure there is a clever BFS
  way of solving this problem, but i'm having trouble finding it. I believe
  that this solution at least minimizes the amount of iterations, although at
  the cost of using more memory than is probably necessary.

  I initially misinterpreted the instructions and didn't understand that if a
  number touches multiple parts, it should be counted twice. So, this one took
  me a long time because I for the life of me I couldn't figure out why they
  kept saying my answer was incorrect!

  iex> Aoc2023.Day3.part_1(:test)
  4361

  iex> Aoc2023.Day3.part_1(:real)
  546563
  """
  def part_1(input_type) do
    {symbols, matrix} = Matrix.parse(input_type)

    symbols
    |> Enum.reduce([], &collect_adjacent_numbers(&1, matrix, &2))
    |> Enum.reduce(0, &(&2 + &1.value))
  end

  @doc """
  Part 2

  ```
  The missing part wasn't the only issue - one of the gears in the engine
  is wrong. A gear is any * symbol that is adjacent to exactly two part
  numbers. Its gear ratio is the result of multiplying those two numbers
  together.

  This time, you need to find the gear ratio of every gear and add them all
  up so that the engineer can figure out which gear needs to be replaced.

  What is the sum of all of the gear ratios in your engine schematic?
  ```

  Strategy:
  Only required a slight modification from part 1. I added the symbol
  value to the symbol accumulator, then filtered for only `*` symbols. I
  probably could optimize the `get_adjacent_numbers` function to bail if
  if detects more than a max #, but I didn't bother.

  iex> Aoc2023.Day3.part_2(:test)
  467835

  iex> Aoc2023.Day3.part_2(:real)
  91031374
  """
  def part_2(input_type) do
    {symbols, matrix} = Matrix.parse(input_type)

    symbols
    |> Stream.filter(&(&1.value == "*"))
    |> Stream.map(&get_adjacent_numbers(&1, matrix))
    |> Stream.map(&calculate_gear_ratio/1)
    |> Enum.reduce(0, &Kernel.+/2)
  end

  defp collect_adjacent_numbers(symbol, matrix, acc) do
    symbol
    |> get_adjacent_numbers(matrix)
    |> Enum.into([])
    |> Enum.concat(acc)
  end

  defp calculate_gear_ratio(%MapSet{} = set) do
    set
    |> Enum.into([])
    |> calculate_gear_ratio()
  end

  defp calculate_gear_ratio([%Number{value: val_1}, %Number{value: val_2}]) do
    val_1 * val_2
  end

  defp calculate_gear_ratio([%Number{} | _]) do
    0
  end

  defp calculate_gear_ratio([]) do
    0
  end

  defp get_adjacent_numbers(%Symbol{x: x, y: y}, matrix) do
    prev_row = [{x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1}]
    row = [{x - 1, y}, {x + 1, y}]
    next_row = [{x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}]

    [prev_row, row, next_row]
    |> Enum.concat()
    |> Enum.reduce(MapSet.new(), &get_adjacent_number(&1, matrix, &2))
  end

  defp get_adjacent_number({x, y}, matrix, acc) do
    case Map.fetch(matrix, {x, y}) do
      :error -> acc
      {:ok, number} -> MapSet.put(acc, number)
    end
  end
end

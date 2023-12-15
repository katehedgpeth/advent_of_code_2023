defmodule Aoc2023.Day1 do
  @moduledoc """
  Day 1
  https://adventofcode.com/2023/day/1
  """
  @doc """
  Part 1:

  ```
  On each line, the calibration value can be found by combining the first digit
  and the last digit (in that order) to form a single two-digit number.

  What is the sum of all of the calibration values?
  ```

  Basic strategy: read each line forwards and backwards, stopping when we reach
  the first digit from each direction. Concat the two returned strings, parse
  into an integer, then reduce to add all the lines.

      iex> Aoc2023.Day1.part_1(:test)
      142

      iex>Aoc2023.Day1.part_1(:real)
      55123
  """
  def part_1(file_type) do
    __MODULE__
    |> Aoc2023.read_input_file(file_type)
    |> Stream.map(&parse_line/1)
    |> Enum.reduce(0, &Kernel.+/2)
  end

  #########################################################

  #

  #

  #

  #########################################################
  #########################################################
  ##
  ##  PRIVATE METHODS
  ##
  #########################################################

  defp parse_line("" <> line) do
    [first_num(line), last_num(line)]
    |> Enum.join("")
    |> String.to_integer()
  end

  defp first_num(line), do: get_num(line, :+, 0)
  defp last_num(line), do: get_num(line, :-, String.length(line) - 1)

  @spec get_num(String.t(), :+ | :-, integer()) :: String.t()
  defp get_num("" <> line, advancer, idx) do
    char = String.at(line, idx)

    if integer?(char),
      do: char,
      else: get_num(line, advancer, apply(Kernel, advancer, [idx, 1]))
  end

  for digit <- ?0..?9 do
    defp integer?(<<unquote(digit)>>), do: true
  end

  defp integer?(_), do: false
end

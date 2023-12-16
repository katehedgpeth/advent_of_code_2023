defmodule Aoc2023.Day2 do
  require Logger

  @moduledoc """
  Day 2
  https://adventofcode.com/2023/day/2
  """

  @max_counts %{
    red: 12,
    green: 13,
    blue: 14
  }

  @doc """
  Part 1

  ```
  Determine which games would have been possible if the bag had been loaded
  with only 12 red cubes, 13 green cubes, and 14 blue cubes. What is the sum
  of the IDs of those games?
  ```

  Strategy: If any set in a game has an instance of a color that is greater
  than the max allowed, ignore that game because it is invalid. Add the
  ids of all the valid lines. (I'm sure I will have to heavily refactor my
  parsing functions for part 2.)

  iex> Aoc2023.Day2.part_1(:test)
  8

  iex> Aoc2023.Day2.part_1(:real)
  2512

  """
  def part_1(input_type) do
    parse_file(input_type)
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

  defp parse_file(input_type) do
    __MODULE__
    |> Aoc2023.read_input_file(input_type)
    |> Stream.map(&parse_line/1)
    |> Enum.reduce(0, &Kernel.+/2)
  end

  defp parse_line(<<"Game ", line::binary>>) do
    [id, cube_sets] = String.split(line, ": ")

    cube_sets
    |> String.split("; ")
    |> Enum.all?(&valid_set?/1)
    |> case do
      true ->
        String.to_integer(id)

      false ->
        0
    end
  end

  defp valid_set?(set) do
    set
    |> String.split(", ")
    |> Enum.all?(&valid_cube?/1)
  end

  defp valid_cube?(cube) do
    [count, color] = String.split(cube, " ")
    count = String.to_integer(count)
    color = String.to_existing_atom(color)

    Map.fetch!(@max_counts, color) >= count
  end
end

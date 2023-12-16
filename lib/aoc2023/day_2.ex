defmodule Aoc2023.Day2.Set do
  defstruct red: 0, green: 0, blue: 0
end

defmodule Aoc2023.Day2 do
  @moduledoc """
  Day 2
  https://adventofcode.com/2023/day/2
  """

  alias __MODULE__.Set

  @max_counts %Set{
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
    input_type
    |> parse_into_sets()
    |> Stream.filter(&valid_game?/1)
    |> Enum.reduce(0, &add_valid_ids/2)
  end

  @doc """
  Part 2

  ```
  The power of a set of cubes is equal to the numbers of red, green,
  and blue cubes multiplied together. The power of the minimum set of
  cubes in game 1 is 48. In games 2-5 it was 12, 1560, 630, and 36,
  respectively. Adding up these five powers produces the sum 2286.

  For each game, find the minimum set of cubes that must have been present.
  What is the sum of the power of these sets?
  ```

  Strategy:
  I altered the parsers a bit to make them reusable.

  For this part, we want to find the largest number for each color
  within a game, so we iterate over all the sets in a game with a simple
  reducer. If any color in a set is larger than the current highest count
  in the accumulator, update the accumulator. Then we simply multiply the
  accumulated values for each game to get the power, and add the power of
  each line.

  iex> Aoc2023.Day2.part_2(:test)
  2286

  iex> Aoc2023.Day2.part_2(:real)
  67335

  """
  def part_2(input_type) do
    input_type
    |> parse_into_sets()
    |> Stream.map(&get_minimum_set/1)
    |> Stream.map(&(&1.red * &1.green * &1.blue))
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

  defp parse_into_sets(input_type) do
    __MODULE__
    |> Aoc2023.read_input_file(input_type)
    |> Stream.map(&parse_line_into_sets/1)
  end

  defp parse_line_into_sets(<<"Game ", line::binary>>) do
    [id, sets] = String.split(line, ": ")
    {id, String.split(sets, "; ")}
  end

  defp add_valid_ids({id, _}, acc) do
    String.to_integer(id) + acc
  end

  defp get_minimum_set({_id, sets}) do
    sets
    |> Enum.map(&String.split(&1, ", "))
    |> Enum.reduce(%Set{}, &reduce_minimum_sets/2)
  end

  defp reduce_minimum_sets(set, acc) do
    set
    |> Enum.map(&parse_cube/1)
    |> Enum.reduce(acc, &update_minimum_color/2)
  end

  defp update_minimum_color(%{count: count, color: color}, acc) do
    Map.update!(acc, color, fn old_count ->
      if old_count > count,
        do: old_count,
        else: count
    end)
  end

  defp valid_game?({_id, sets}) do
    Enum.all?(sets, &valid_set?/1)
  end

  defp valid_set?(set) do
    set
    |> String.split(", ")
    |> Enum.all?(&valid_cube?/1)
  end

  defp valid_cube?(cube) do
    %{count: count, color: color} = parse_cube(cube)
    Map.fetch!(@max_counts, color) >= count
  end

  defp parse_cube(cube) do
    [count, color] = String.split(cube, " ")

    %{
      count: String.to_integer(count),
      color: String.to_existing_atom(color)
    }
  end
end

defmodule Aoc2023Test do
  use ExUnit.Case, async: true

  doctest Aoc2023
  doctest Aoc2023.Day1
  doctest Aoc2023.Day2
  doctest Aoc2023.Day3
  # doctest Aoc2023.Day4
  # doctest Aoc2023.Day5
  doctest Aoc2023.Day6
  doctest Aoc2023.Day7
  doctest Aoc2023.Day8
  doctest Aoc2023.Day9

  test "greets the world" do
    assert Aoc2023.hello() == :world
  end
end

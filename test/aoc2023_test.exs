defmodule Aoc2023Test do
  use ExUnit.Case, async: true
  doctest Aoc2023
  doctest Aoc2023.Day1
  doctest Aoc2023.Day2

  test "greets the world" do
    assert Aoc2023.hello() == :world
  end
end

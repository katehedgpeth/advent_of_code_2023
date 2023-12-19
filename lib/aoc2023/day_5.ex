defmodule Aoc2023.Day5 do
  require Logger
  require Aoc2023

  alias Aoc2023.Day5.Agent

  @moduledoc """
  Day 5
  https://adventofcode.com/2023/day/5
  """

  @doc """
  Part 1

  (this description is super complicated)

  ```
  The almanac starts by listing which seeds need to be planted:
  seeds 79, 14, 55, and 13.

  The rest of the almanac contains a list of maps which describe
  how to convert numbers from a source category into numbers in a
  destination category. That is, the section that starts with
  seed-to-soil map: describes how to convert a seed number (the
  source) to a soil number (the destination). This lets the gardener
  and his team know which soil to use with which seeds, which water
  to use with which fertilizer, and so on.

  Rather than list every source number and its corresponding
  destination number one by one, the maps describe entire ranges of
  numbers that can be converted. Each line within a map contains three
  numbers: the destination range start, the source range start, and
  the range length.


  Any source numbers that aren't mapped correspond to the same
  destination number. So, seed number 10 corresponds to soil number 10.

  What is the lowest location number that corresponds to any of the
  initial seed numbers?
  ```

  Strategy:
  This one's going to be all about parsing. I clearly can't use the normal
  stream reader that I've used for all the other modules. I'll have to read
  each line and determine what to do with it based on what the first
  characters are.

  ...... hours later ..........

  So, yes this was very much about parsing, but there was also a trick to it.
  I was able to write something that worked for the test input pretty quickly,
  but when I ran the real input it kept timing out, and it took me much longer
  than it should have to figure out why. If I had looked at the input file more
  closely it might have been more obvious to me.

  My original strategy was to map over the ranges and save the mapped value for
  each ID into memory. But, since the ranges were so large (like, hundreds of
  millions), that was a ton of data and a ton of processing.

  I refactored to use a GenServer to parse the file while I was trying to figure
  out the root cause of the timeouts, and I decided to leave it because it's a
  nice abstraction and makes the parsing run very fast.

  Ultimately, to solve my mapper issue I created a data structure that saved the
  beginning and end of the range, and so each id gets evaluated against the range
  and the mapped value gets calculated at runtime.

  iex> Aoc2023.Day5.part_1(:test)
  35

  iex> Aoc2023.Day5.part_1(:real)
  178159714
  """

  def part_1(input_type) do
    {:ok, agent} = Agent.start_link(input_type: input_type)

    agent
    |> GenServer.call(:state)
    |> __MODULE__.Part1.get_lowest_location()
  end

  @doc """
  Part 2

  ```
  Re-reading the almanac, it looks like the seeds: line actually describes
  ranges of seed numbers.  The values on the initial seeds: line come in
  pairs. Within each pair, the first value is the start of the range and
  the second value is the length of the range.

  So, in the first line of the example above:

  seeds: 79 14 55 13

  This line describes two ranges of seed numbers to be planted in the garden.
  The first range starts with seed number 79 and contains 14 values: 79,
  80, ..., 91, 92. The second range starts with seed number 55 and contains
  13 values: 55, 56, ..., 66, 67.

  What is the lowest location number that corresponds to any of the initial
  seed numbers?
  ```

  Strategy:
  Ok, so this is going to have the same problem as before, there's just going
  to be a shitload of data to crunch. It doesn't seem like there's anything we
  can do at the beginning to rule out some seed ids, but maybe I'm wrong about
  that.

  Actually, maybe I could do a reverse search - order the location
  numbers from lowest to highest, then map over them until I find the first
  location ID that actually matches a seed id. I'm going to try that.

  ...........

  Well, my first attempt at implementing the reverse-search idea didn't work.
  I only have the location ranges to start with, and I'm not sure that it would
  actually save me any work to use that as a starting point. There is not a
  guarantee that a lower seed ID corresponds to a lower location. I'm going to
  try again and just iterate over the seed ids.

  iex> Aoc2023.Day5.part_2(:test)
  46
  """
  def part_2(input_type) do
    {:ok, agent} = Agent.start_link(input_type: input_type)

    agent
    |> GenServer.call(:state)
    |> __MODULE__.Part2.get_lowest_location()
  end
end

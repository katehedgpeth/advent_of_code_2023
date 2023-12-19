defmodule Aoc2023.Day5 do
  require Logger
  require Aoc2023

  alias Aoc2023.Day5.State
  alias Aoc2023.Day5.Mapper
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
    |> get_lowest_location()
  end

  defp get_lowest_location(%State{seed_ids: seed_ids} = state) do
    seed_ids
    |> Enum.reduce([], &map_seed_id(&1, &2, state))
    |> Enum.reduce(nil, &_get_lowest_location/2)
  end

  defp _get_lowest_location({_, %{location: location}}, lowest)
       when lowest == nil or location < lowest,
       do: location

  defp _get_lowest_location({_, %{location: _}}, lowest),
    do: lowest

  def map_seed_ids(seed_ids, pid) do
    Enum.reduce(seed_ids, [], &map_seed_id(&1, &2, pid))
  end

  defp map_seed_id(id, acc, state) do
    mapped = do_map_seed_id(%{seed: id}, :seed, state)
    [{id, mapped} | acc]
  end

  defp do_map_seed_id(acc, :location, %State{}) do
    acc
  end

  defp do_map_seed_id(acc, source, %State{} = state) do
    with {_, {{^source, destination}, maps}} <-
           {source, Enum.find(state.mappers, &source?(&1, source))},
         source_id <- Map.fetch!(acc, source),
         destination_id <- Mapper.map(source_id, maps) do
      acc
      |> Map.put(destination, destination_id)
      |> do_map_seed_id(destination, state)
    else
      {source, nil} ->
        raise """
        Cannot find maps for source:

        source=#{source}

        mappers=#{inspect(Map.keys(state.mappers))}
        """
    end
  end

  defp source?({{source, _dest}, _mapper}, seeking), do: source == seeking
end

defmodule Aoc2023.Day5.Part1 do
  alias Aoc2023.Day5.State

  def get_lowest_location(%State{seed_ids: seed_ids} = state) do
    seed_ids
    |> Enum.reduce([], &map_seed_id(&1, &2, state))
    |> Enum.reduce(nil, &_get_lowest_location/2)
  end

  defp _get_lowest_location({_, %{location: location}}, lowest)
       when lowest == nil or location < lowest,
       do: location

  defp _get_lowest_location({_, %{location: _}}, lowest),
    do: lowest

  def map_seed_id(id, acc, state) do
    [{id, State.map_seed_id(id, state)} | acc]
  end
end

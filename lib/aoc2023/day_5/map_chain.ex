defmodule Aoc2023.Day5.MapChain do
  alias Aoc2023.Day5.{
    Agent,
    State,
    Mapper
  }

  defguard is_src_or_dest(src_or_dest) when src_or_dest in [:src, :dest]

  @doc """
  Maps a seed id to a location id. This function should always return a number.
  """
  def seed_id_to_location_id!(seed_id, agent)
      when is_integer(seed_id) and is_pid(agent) do
    %State{mappers: mappers} = Agent.state(agent)
    map_forward(seed_id, :seed, mappers)
  end

  @doc """
  Maps a location id to a seed id. Returns {:ok, seed_id} if the seed id exists
  in state, otherwise :no_match
  """
  def location_id_to_seed_id(location_id, agent)
      when is_integer(location_id) and is_pid(agent) do
    %State{mappers: mappers} = Agent.state(agent)

    location_id
    |> map_backward(:location, mappers)
    |> validate_seed_id(agent)
  end

  defp map_forward(location_id, :location, _mappers) do
    location_id
  end

  defp map_forward(src_id, src, mappers) do
    {{^src, dest}, maps} = find_maps_for(mappers, src, :src)

    maps
    |> map_id(src_id, :src)
    |> map_forward(dest, mappers)
  end

  defp map_backward(seed_id, :seed, _mappers) do
    seed_id
  end

  defp map_backward(dest_id, dest, mappers) do
    {{src, ^dest}, maps} = find_maps_for(mappers, dest, :dest)

    maps
    |> map_id(dest_id, :dest)
    |> map_backward(src, mappers)
  end

  defp map_id(maps, id, src_or_dest) when is_src_or_dest(src_or_dest) do
    maps
    |> Enum.find(&id_in_range?(&1, id, src_or_dest))
    |> _map_id(id, src_or_dest)
  end

  defp _map_id(nil, id, _src_or_dest) do
    id
  end

  defp _map_id({_, %Mapper{src: src, dest: dest}}, id, src_or_dest) do
    diff = dest - src

    case src_or_dest do
      :src -> id + diff
      :dest -> id - diff
    end
  end

  defp find_maps_for(
         mappers,
         src,
         src_or_dest
       )
       when is_src_or_dest(src_or_dest) do
    Enum.find(mappers, &match?(&1, src, src_or_dest))
  end

  defp match?({{maybe_src, _dest}, %MapSet{}}, src, :src), do: maybe_src == src
  defp match?({{_src, maybe_dest}, %MapSet{}}, dest, :dest), do: maybe_dest == dest

  defp id_in_range?({_, %{} = map}, id, src_or_dest)
       when is_src_or_dest(src_or_dest) do
    start = Map.fetch!(map, src_or_dest)
    id in Range.new(start, start + map.range - 1)
  end

  defp validate_seed_id(seed_id, agent) do
    agent
    |> Agent.seed_ids()
    |> seed_id_exists?(seed_id)
    |> case do
      true -> {:ok, seed_id}
      false -> :no_match
    end
  end

  defp seed_id_exists?([id | _] = seed_ids, seed_id) when is_integer(id) do
    Enum.member?(seed_ids, seed_id)
  end

  defp seed_id_exists?([%Range{} | _] = ranges, seed_id) do
    Enum.any?(ranges, &(seed_id in &1))
  end
end

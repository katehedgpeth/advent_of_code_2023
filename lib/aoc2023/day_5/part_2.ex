defmodule Aoc2023.Day5.Part2 do
  alias Aoc2023.Day5.{
    State,
    Mapper
  }

  def get_lowest_location(%State{} = state) do
    state
    |> get_mappers!(:location)
    |> find_lowest_ranged_location(state)
  end

  defp get_mappers!(%State{mappers: mappers}, category) do
    case Enum.find(mappers, &match_category?(&1, category)) do
      nil -> raise "Cannot find mappers for category #{category}"
      match -> match
    end
  end

  defp match_category?({{:seed, _}, _}, :seed), do: true
  defp match_category?({{_, dest}, _}, category), do: dest == category

  defp find_lowest_ranged_location({src_dest, %MapSet{} = set}, state) do
    find_lowest_ranged_location({src_dest, Enum.to_list(set)}, state)
  end

  defp find_lowest_ranged_location(
         {{source, :location}, [{{id, _last}, %Mapper{} = mapper} | _]},
         state
       ) do
    case map_to_seed_id(id, source, mapper, state) do
      {:ok, seed_id} -> State.map_seed_id(seed_id, state)
    end
  end

  defp map_to_seed_id(id, source, _mapper, state) do
    _map_to_seed_id(id, source, state)
  end

  @spec _map_to_seed_id(integer(), atom(), State.t()) ::
          {:ok, integer()} | :not_found
  defp _map_to_seed_id(id, :seed, %State{} = state) do
    {_, mappers} = get_mappers!(state, :seed)
    {:ok, %Mapper{diff: diff}} = Mapper.reverse_find(id, mappers)
    get_matching_seed_id(id - diff, state)
  end

  defp _map_to_seed_id(
         id,
         source,
         %State{} = state
       ) do
    {{next_source, ^source}, mappers} = get_mappers!(state, source)

    id
    |> Mapper.reverse_map(mappers)
    |> _map_to_seed_id(next_source, state)
  end

  defp get_matching_seed_id(seed_id, %State{seed_ids: seed_ids})
       when is_integer(seed_id) do
    seed_ids
    |> Enum.chunk_every(2)
    |> Enum.map(fn [first, range] -> {first, first + range} end)
    |> Enum.find(&seed_id_in_range?(&1, seed_id))
    |> case do
      nil -> :not_found
      {_src, _dst} -> {:ok, seed_id}
    end
  end

  defp seed_id_in_range?({first, last}, seed_id) do
    seed_id >= first and seed_id <= last
  end
end

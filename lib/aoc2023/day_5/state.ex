defmodule Aoc2023.Day5.State do
  alias Aoc2023.Day5.Mapper

  defstruct input_type: nil,
            category_line_ranges: %{},
            length: 0,
            parent: nil,
            remaining_mappers: [],
            seed_ids: [],
            seed_id_type: :integer,
            finished_parsing: %{
              categories: false,
              mappers: false,
              seed_ids: false
            },
            mappers: %{
              {:seed, :soil} => MapSet.new(),
              {:soil, :fertilizer} => MapSet.new(),
              {:fertilizer, :water} => MapSet.new(),
              {:water, :light} => MapSet.new(),
              {:light, :temperature} => MapSet.new(),
              {:temperature, :humidity} => MapSet.new(),
              {:humidity, :location} => MapSet.new()
            }

  def new(input_type: input_type, seed_id_type: seed_id_type)
      when seed_id_type in [:integer, :range] and input_type in [:test, :real] do
    %__MODULE__{input_type: input_type, seed_id_type: seed_id_type}
  end

  def map_seed_id(id, %__MODULE__{} = state) do
    _map_seed_id(%{seed: id}, :seed, state)
  end

  defp _map_seed_id(acc, :location, %__MODULE__{}) do
    acc
  end

  defp _map_seed_id(acc, source, %__MODULE__{} = state) do
    {{^source, destination}, maps} =
      Enum.find(
        state.mappers,
        &Mapper.source?(&1, source)
      )

    source_id = Map.fetch!(acc, source)
    destination_id = Mapper.map(source_id, maps)

    acc
    |> Map.put(destination, destination_id)
    |> _map_seed_id(destination, state)
  end

  def finished_parsing?(%__MODULE__{
        finished_parsing: %{
          categories: true,
          mappers: true,
          seed_ids: true
        }
      }),
      do: true

  def finished_parsing?(%__MODULE__{}), do: false

  def set_parent(%__MODULE__{} = state, parent) do
    %{state | parent: parent}
  end

  def add_mapper_idx_to_state({_line, idx}, state) do
    Map.update!(state, :remaining_mappers, &[idx | &1])
  end

  def save_seed_ids(seed_ids, state) do
    state
    |> Map.replace!(:seed_ids, seed_ids)
    |> mark_finished(:seed_ids)
  end

  def add_category_line_range(%__MODULE__{} = state, {src, dest}, %Range{} = range) do
    Map.update!(state, :category_line_ranges, &Map.put(&1, {src, dest}, range))
  end

  def save_mapper_to_state(%__MODULE__{} = state, info) do
    state
    |> Map.update!(:mappers, &_save_mapper_to_state(&1, info))
    |> Map.update!(:remaining_mappers, &remove_mapper_num(&1, info.line))
    |> case do
      %__MODULE__{remaining_mappers: []} = state ->
        mark_finished(state, :mappers)

      %__MODULE__{} = state ->
        state
    end
  end

  defp _save_mapper_to_state(mappers, %{
         category: category,
         src: src,
         dest: dest,
         range: range
       }) do
    Map.update!(
      mappers,
      category,
      &Mapper.insert(&1, Mapper.new(src: src, dest: dest, range: range))
    )
  end

  def update_category_line_ranges(%__MODULE__{} = state) do
    state
    |> Map.update!(:category_line_ranges, &_update_category_line_ranges/1)
    |> mark_finished(:categories)
  end

  defp _update_category_line_ranges(ranges) do
    ranges
    |> Enum.map(&update_category_line_range(&1, ranges))
    |> Enum.into(%{})
  end

  defp update_category_line_range({category, range}, ranges) do
    {category, Enum.reduce(ranges, range, &_update_category_line_range/2)}
  end

  defp _update_category_line_range(
         {_, %Range{first: next}},
         %Range{first: first, last: last}
       )
       when next > first and next < last,
       do: Range.new(first, next)

  defp _update_category_line_range({_, %Range{}}, %Range{} = range) do
    range
  end

  defp mark_finished(%__MODULE__{} = state, key) do
    Map.update!(state, :finished_parsing, &Map.replace!(&1, key, true))
  end

  defp remove_mapper_num(nums, line_num) do
    nums
    |> MapSet.new()
    |> MapSet.delete(line_num)
    |> Enum.into([])
  end
end

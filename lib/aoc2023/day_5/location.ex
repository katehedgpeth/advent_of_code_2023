defmodule Aoc2023.Day5.Location do
  alias Aoc2023.Day5.{
    Agent,
    Mapper,
    State,
    MapChain,
    BinarySearch
  }

  @match_fn &MapChain.location_id_to_seed_id/2

  def lowest(agent, step_size) when is_pid(agent) do
    agent
    |> mapped_range()
    |> Map.replace!(:first, 0)
    |> step_range(agent, step_size)
    |> BinarySearch.search_range(agent)

    # |> _lowest(agent)
  end

  def mapped_range(agent) do
    %State{mappers: %{{:humidity, :location} => maps}} = Agent.state(agent)

    [first | rest] = Enum.sort_by(maps, &get_location/1)
    last = List.last(rest)

    first
    |> get_location()
    |> Range.new(get_location(last))
  end

  defp get_location({{_, _}, %Mapper{dest: location}}), do: location

  def _lowest(%Range{first: same, last: same}, agent) do
    @match_fn.(same, agent)
  end

  def _lowest(
        %Range{first: last_nil, last: maybe_location},
        agent
      )
      when maybe_location - last_nil == 1 do
    @match_fn.(maybe_location, agent)
  end

  def _lowest(
        %Range{first: first, last: last} = range,
        agent
      )
      when first < last do
    case @match_fn.(first, agent) do
      {:ok, _seed_id} ->
        {:ok, first}

      :no_match ->
        _lowest(%{range | first: first + 1}, agent)

        # |> split_range()
        # |> elem(1)
        # |> _lowest(agent)
    end
  end

  # defp split_range(%Range{} = range) do
  #   Range.split(
  #     range,
  #     range
  #     |> Range.size()
  #     |> Kernel./(2)
  #     |> floor()
  #   )
  # end

  defp step_range(
         %Range{} = range,
         agent,
         step_size,
         previously_stepped \\ 0
       ) do
    step = calculate_step(range, step_size, previously_stepped)

    case @match_fn.(step, agent) do
      {:ok, _seed_id} ->
        Range.new(step - step_size, step)

      # %{range | last: calculate_step(range, step_size, previously_stepped)}

      :no_match ->
        step_range(range, agent, step_size, previously_stepped + 1)
    end

    # %{range | last: first + 1000}
  end

  defp calculate_step(%Range{} = range, step_size, previously_stepped) do
    range.first
    |> Range.new(range.last, step_size)
    |> Enum.at(previously_stepped + 1)
  end
end

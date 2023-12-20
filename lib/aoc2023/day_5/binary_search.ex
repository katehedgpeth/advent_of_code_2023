defmodule Aoc2023.Day5.BinarySearch do
  alias Aoc2023.Day5.{
    MapChain
  }

  @match_fn &MapChain.location_id_to_seed_id/2

  def search_range(
        %Range{first: location, last: location},
        _agent
      ) do
    {:ok, location}
  end

  def search_range(
        %Range{first: first, last: last} = range,
        agent
      )
      when first < last do
    {%Range{last: middle}, %Range{}} = split_range(range)

    case @match_fn.(middle, agent) do
      {:ok, _seed_id} ->
        range
        |> split_range()
        |> elem(0)
        |> search_range(agent)

      :no_match ->
        range
        |> split_range()
        |> elem(1)
        |> search_range(agent)
    end
  end

  defp split_range(%Range{} = range) do
    Range.split(
      range,
      range
      |> Range.size()
      |> Kernel./(2)
      |> floor()
    )
  end
end

defmodule Aoc2023.Day6.WaysOfWinning do
  alias Aoc2023.BinarySearch

  def calculate(%{time: total_time, distance: distance}, method)
      when method in [:brute_force, :optimized] do
    0
    |> Range.new(total_time)
    |> get_winning_methods(total_time, distance, method)
    |> Enum.count()
  end

  defp get_winning_methods(range, total_time, distance, :brute_force) do
    range
    |> Enum.map(&calculate_distance(&1, total_time))
    |> Enum.filter(&(&1.distance > distance))
  end

  defp get_winning_methods(range, total_time, winning_distance, :optimized) do
    low =
      BinarySearch.search_range(
        range,
        &calculate_optimized(&1, total_time, winning_distance, :>)
      )

    high =
      low
      |> Range.new(range.last)
      |> BinarySearch.search_range(
        &calculate_optimized(&1, total_time, winning_distance, :<)
      )

    Range.new(low, high - 1)
  end

  defp calculate_distance(held_time, total_time) do
    %{held_time: held_time, distance: held_time * (total_time - held_time)}
  end

  @spec calculate_optimized(integer(), integer(), integer(), :< | :>) ::
          {:ok, map()} | :error
  defp calculate_optimized(time, total_time, winning_distance, comparator) do
    calc =
      calculate_distance(time, total_time)

    if apply(Kernel, comparator, [calc.distance, winning_distance]),
      do: {:ok, calc},
      else: :error
  end
end

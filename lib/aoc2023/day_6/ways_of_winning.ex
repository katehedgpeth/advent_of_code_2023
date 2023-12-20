defmodule Aoc2023.Day6.WaysOfWinning do
  def calculate(%{time: total_time, distance: distance}) do
    total_time
    |> Range.new(0)
    |> Enum.map(&calculate_distance(&1, total_time))
    |> Enum.filter(&(&1.distance > distance))
    |> Enum.count()
  end

  def calculate_distance(held_time, total_time) do
    %{held_time: held_time, distance: held_time * (total_time - held_time)}
  end
end

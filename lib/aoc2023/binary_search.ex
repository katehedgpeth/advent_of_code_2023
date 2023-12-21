defmodule Aoc2023.BinarySearch do
  @spec search_range(Range.t(), (integer() -> {:ok, any()} | :error)) ::
          integer()
  def search_range(range, test_fn)

  def search_range(
        %Range{first: location, last: location},
        _test_fn
      ) do
    location
  end

  def search_range(
        %Range{} = range,
        test_fn
      ) do
    {%Range{last: middle}, %Range{}} = split_range(range)

    case test_fn.(middle) do
      {:ok, _seed_id} ->
        range
        |> split_range()
        |> elem(0)
        |> search_range(test_fn)

      :error ->
        range
        |> split_range()
        |> elem(1)
        |> search_range(test_fn)
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

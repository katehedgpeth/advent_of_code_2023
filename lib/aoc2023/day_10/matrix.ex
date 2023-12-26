defmodule Aoc2023.Day10.Matrix do
  use Agent
  alias Aoc2023.Day10

  @symbol_map %{
    "|" => {:north, :south},
    "-" => {:east, :west},
    "L" => {:north, :east},
    "J" => {:north, :west},
    "7" => {:south, :west},
    "F" => {:south, :east},
    "." => :ground,
    "S" => :start
  }

  @type direction() :: :east | :north | :south | :west
  @type coords() :: {integer(), integer()}

  @symbols Map.values(@symbol_map)

  def start_link(opts) do
    Agent.start_link(fn -> init(opts) end)
  end

  def init(input_type: input_type) do
    matrix = parse_matrix(input_type)
    start = find_start(matrix)

    %{
      matrix: matrix,
      start: start
    }
  end

  def get_start(pid) do
    Agent.get(pid, &Map.fetch!(&1, :start))
  end

  def get_cell(pid, {x, y}) do
    Agent.get(pid, &_get_cell(&1, {x, y}))
  end

  def go(:north, {x, y}), do: {x, y - 1}
  def go(:south, {x, y}), do: {x, y + 1}
  def go(:west, {x, y}), do: {x - 1, y}
  def go(:east, {x, y}), do: {x + 1, y}

  def opposite_direction(direction) do
    case direction do
      :north -> :south
      :south -> :north
      :west -> :east
      :east -> :west
    end
  end

  @spec check_connection(pid(), [
          {:direction, direction()} | {:from, {any(), any()}}
        ]) ::
          {:error, :edge | :ground | {:no_match, any()}}
          | {:ok, {coords(), direction() | :start}}
  def check_connection(pid, from: from, direction: direction) do
    to = go(direction, from)

    from_direction = opposite_direction(direction)

    case get_cell(pid, to) do
      :error ->
        {:error, :edge}

      {:ok, :ground} ->
        {:error, :ground}

      {:ok, :start} ->
        {:ok, {to, :start}}

      {:ok, {^from_direction, next_direction}} ->
        {:ok, {to, next_direction}}

      {:ok, {next_direction, ^from_direction}} ->
        {:ok, {to, next_direction}}

      {:ok, cell} ->
        {:error, {:no_match, cell}}
    end
  end

  defp _get_cell(%{matrix: matrix}, {x, y}) do
    with {:ok, row} <- Map.fetch(matrix, y) do
      Map.fetch(row, x)
    end
  end

  defp find_start(%{} = matrix) do
    matrix
    |> Enum.into([])
    |> Enum.sort_by(&elem(&1, 0))
    |> find_start()
  end

  defp find_start([{y, line} | rest]) do
    case Enum.find(line, &start?/1) do
      nil ->
        find_start(rest)

      {x, :start} ->
        {x, y}
    end
  end

  defp start?({_idx, symbol}) when symbol in @symbols do
    symbol == :start
  end

  def parse_matrix(input_type) do
    Day10
    |> Aoc2023.read_input_file(input_type)
    |> Stream.map(&parse_line/1)
    |> Stream.with_index()
    |> Stream.map(&reverse_idx/1)
    |> Enum.sort_by(&elem(&1, 0))
    |> Map.new()
  end

  defp parse_line(line) do
    line
    |> String.split("", trim: true)
    |> Enum.map(&Map.fetch!(@symbol_map, &1))
    |> Enum.with_index()
    |> Enum.map(&reverse_idx/1)
    |> Enum.sort_by(&elem(&1, 0))
    |> Map.new()
  end

  defp reverse_idx({val, idx}), do: {idx, val}
end

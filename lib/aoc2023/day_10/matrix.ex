defmodule Aoc2023.Day10.Matrix do
  use Agent
  alias Aoc2023.Day10
  require Logger

  @type direction() :: :east | :north | :south | :west
  @type coords() :: {integer(), integer()}
  @type symbol() :: {direction(), direction()}
  @type matrix() :: %{
          integer() => %{
            integer() => symbol()
          }
        }

  @symbol_map %{
    "|" => {:north, :south},
    "-" => {:east, :west},
    "L" => {:north, :east},
    "J" => {:north, :west},
    "7" => {:south, :west},
    "F" => {:south, :east},
    "." => :ground,
    "I" => :ground,
    "S" => :start
  }

  @reverse_symbols @symbol_map
                   |> Map.new(&{elem(&1, 1), elem(&1, 0)})

  @symbols Map.values(@symbol_map)

  def start_link(opts) do
    Agent.start_link(fn -> init(opts) end)
  end

  def init(input_type: input_type) do
    init(stream: Aoc2023.read_input_file(Day10, input_type))
  end

  def init(stream: stream) do
    matrix = parse_matrix(stream)
    start = find_start(matrix)

    %{
      matrix: matrix,
      start: start,
      loop: walk_loop(%{matrix: matrix, start: start}),
      inners: count_inner_pieces(stream)
    }
  end

  def get_loop(pid) do
    Agent.get(pid, & &1.loop)
  end

  @doc """
  Returns the number of boundary points in the loop.
  The loop stored in the agent includes the start point twice
  (first and last) in order to correctly calculate the area
  with the shoelace formula. So, the actual count is
  length(loop) - 1.
  """
  def boundary_point_count(pid) when is_pid(pid) do
    Agent.get(pid, &(length(&1.loop) - 1))
  end

  def print(pid) do
    loop =
      pid
      |> walk_loop()
      |> MapSet.new()

    pid
    |> Agent.get(& &1.matrix)
    |> Enum.map(&print_line(&1, loop))
    |> Enum.join("")
  end

  defp print_line({y, line}, loop) do
    "\n" <>
      (line
       |> Enum.map(&print_char(&1, y, loop))
       |> Enum.join(""))
  end

  defp print_char({x, symbol}, y, loop) do
    if MapSet.member?(loop, {x, y}),
      do: Map.fetch!(@reverse_symbols, symbol),
      else: " "
  end

  defp count_inner_pieces(stream) do
    Enum.reduce(stream, 0, &_count_inner_pieces/2)
  end

  defp _count_inner_pieces(line, acc) do
    String.replace(line, ~r/[^I]/, "")
    |> String.length()
    |> Kernel.+(acc)
  end

  def get_start(pid) do
    Agent.get(pid, &Map.fetch!(&1, :start))
  end

  def get_inner_count(pid) do
    Agent.get(pid, &Map.fetch!(&1, :inners))
  end

  def get_cell(pid, {x, y}) do
    Agent.get(pid, &_get_cell(&1.matrix, {x, y}))
  end

  def get_cell!(pid, {x, y}) do
    case get_cell(pid, {x, y}) do
      {:ok, cell} -> cell
      :error -> raise "cell {#{x}, #{y}} not found in matrix"
    end
  end

  def get_line!(pid, y) do
    Agent.get(pid, &(&1 |> Map.fetch!(:matrix) |> Map.fetch!(y)))
  end

  def go(:north, {x, y}), do: {x, y - 1}
  def go(:south, {x, y}), do: {x, y + 1}
  def go(:west, {x, y}), do: {x - 1, y}
  def go(:east, {x, y}), do: {x + 1, y}

  def x({x, y}) when is_integer(x) and is_integer(y), do: x
  def y({x, y}) when is_integer(x) and is_integer(y), do: y

  def opposite_direction(direction) do
    case direction do
      :north -> :south
      :south -> :north
      :west -> :east
      :east -> :west
    end
  end

  @spec check_connection(pid() | matrix(), [
          {:direction, direction()} | {:from, {any(), any()}}
        ]) ::
          {:error, :edge | :ground | {:no_match, any()}}
          | {:ok, {coords(), direction() | :start}}
  def check_connection(pid, opts) when is_pid(pid) do
    pid
    |> Agent.get(& &1)
    |> check_connection(opts)
  end

  def check_connection(%{0 => _} = matrix, from: from, direction: direction) do
    to = go(direction, from)

    from_direction = opposite_direction(direction)

    case _get_cell(matrix, to) do
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

  defp _get_cell(%{0 => _} = matrix, {x, y}) do
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

  def parse_matrix(stream) do
    stream
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

  defp walk_loop(matrix) when is_pid(matrix) do
    matrix
    |> Agent.get(& &1)
    |> walk_loop()
  end

  defp walk_loop(%{start: {x, y}, matrix: matrix}) do
    walk([:north, :east, :south, :west], {x, y}, matrix, [])
  end

  defp walk([:start], {x, y}, _matrix, breadcrumbs) do
    [{x, y} | breadcrumbs]
  end

  defp walk([direction | rest], {x, y}, matrix, breadcrumbs) do
    case check_connection(matrix, from: {x, y}, direction: direction) do
      {:error, _error} ->
        walk(rest, {x, y}, matrix, breadcrumbs)

      {:ok, {{new_x, new_y}, new_direction}} ->
        walk(
          [new_direction],
          {new_x, new_y},
          matrix,
          [{x, y} | breadcrumbs]
        )
    end
  end
end

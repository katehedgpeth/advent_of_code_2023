defmodule Aoc2023.Day10 do
  alias __MODULE__.Matrix

  @doc """
  We are parsing a graph to determine the length of a loop.

  - `|` is a vertical pipe connecting north and south.
  - `-` is a horizontal pipe connecting east and west.
  - `L` is a 90-degree bend connecting north and east.
  - `J` is a 90-degree bend connecting north and west.
  - `7` is a 90-degree bend connecting south and west.
  - `F` is a 90-degree bend connecting south and east.
  - `.` is ground; there is no pipe in this tile.
  - `S` is the starting position.

  7-F7-
  .FJ|7
  SJLL7
  |F--J
  LJ.LJ

  There is a pipe on the starting tile, but your sketch doesn't show
  what shape the pipe has.

  Find the single giant loop starting at S. How many steps along the
  loop does it take to get from the starting position to the point
  farthest from the starting position?

  ----------

  First we'll parse the grid into a matrix, then we'll do a BFS
  starting at S to find the loop.

  iex> Aoc2023.Day10.part_1(:test)
  8

  iex> Aoc2023.Day10.part_1(:real)
  6864

  """
  def part_1(input_type) do
    {:ok, matrix} = Matrix.start_link(input_type: input_type)

    matrix
    |> Matrix.get_start()
    |> walk_loop(matrix)
    |> length()
    |> Integer.floor_div(2)
  end

  defp walk_loop({x, y}, matrix) do
    walk([:north, :south, :east, :west], {x, y}, matrix, [])
  end

  defp walk([:start], _, _matrix, breadcrumbs) do
    Enum.reverse(breadcrumbs)
  end

  defp walk([direction | rest], {x, y}, matrix, breadcrumbs) do
    case Matrix.check_connection(matrix, from: {x, y}, direction: direction) do
      {:error, _error} ->
        walk(rest, {x, y}, matrix, breadcrumbs)

      {:ok, {{new_x, new_y}, new_direction}} ->
        walk([new_direction], {new_x, new_y}, matrix, [{x, y} | breadcrumbs])
    end
  end
end

defmodule Aoc2023.Day10 do
  alias __MODULE__.Matrix
  require Matrix
  require Logger

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
    |> Matrix.boundary_point_count()
    |> Integer.floor_div(2)
  end

  @doc """
  Now we are being asked to find the number of points that
  are fully enclosed by the loop (i.e., not including the
  boundary points).

  Not gonna lie, this took me way, way, way longer than
  these few lines of code make it seem. I eventually broke
  down and looked at solutions on Reddit - even after that,
  my application of shoelace and pick's kept giving me the
  wrong number. I eventually had to break things down and
  write tests for every atomic piece of the pipeline to
  figure out where the calculations were going sideways.
  (I've deleted those tests.)

  iex> Aoc2023.Day10.part_2(:test)
  1

  iex> Aoc2023.Day10.part_2(:test2)
  8

  iex> Aoc2023.Day10.part_2(:real)
  349
  """
  def part_2(input_type) do
    {:ok, matrix} = Matrix.start_link(input_type: input_type)

    matrix
    |> Matrix.get_loop()
    |> calculate_area(0)
    |> calculate_inner_points(Matrix.boundary_point_count(matrix))
  end

  @doc """
  Uses the Shoelace formula to calculate the area of a
  polygon with integer coordinates:

         |x1   x2|                 |x2   x3|
  2A =   |   X   |          +      |   X   |
         |y1   y2|                 |y2   y3|

  ((x1 * y2) - (x2 * y1)) + ((x2 * y3) - (x3 * y2))
  """

  def calculate_area([next, next_1 | rest], acc) do
    calculate_area(
      [next_1 | rest],
      shoelace_acc(next, next_1, acc)
    )
  end

  def calculate_area([_last], area) do
    area
    |> Integer.floor_div(2)
    |> abs()
  end

  defp shoelace_acc({x1, y1}, {x2, y2}, acc) do
    left = x1 * y2
    right = x2 * y1

    acc + left - right
  end

  @doc """
    Based on Pick's theorem to calculate the area of a polygon:
    A = i + (b / 2) - 1

    variables:
    A = area
    i = count of inner points
    b = count of boundary points


    We know A and b, so we change the formula to get i:

    A + 1 = i + (b / 2)
    A + 1 - (b / 2) = i
  """
  def calculate_inner_points(area, boundary_points) do
    area + 1 - Integer.floor_div(boundary_points, 2)
  end
end

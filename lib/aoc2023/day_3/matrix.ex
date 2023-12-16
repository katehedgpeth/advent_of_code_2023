defmodule Aoc2023.Day3.Number do
  defstruct [:value, :x_range, :y]

  @type t() :: %__MODULE__{
          value: integer(),
          x_range: Range.t(),
          y: integer()
        }
end

defmodule Aoc2023.Day3.Symbol do
  defstruct [:x, :y]
end

defmodule Aoc2023.Day3.Line do
  defstruct [:y, :raw, numbers: [], symbols: []]

  @type t() :: %__MODULE__{
          y: integer(),
          raw: String.t(),
          numbers: list(Number.t())
        }
end

defmodule Aoc2023.Day3.Matrix do
  alias Aoc2023.{
    Day3,
    Day3.Line,
    Day3.Number,
    Day3.Symbol
  }

  defstruct lines: [], numbers: [], symbols: []

  @digits Range.new(0, 9)
          |> Enum.map(&Integer.to_string(&1, 10))

  def parse(input_type) do
    Day3
    |> Aoc2023.read_input_file(input_type)
    |> Stream.with_index()
    |> Stream.map(&parse_line/1)
    |> Enum.reduce({[], %{}}, &reduce_line/2)
  end

  defp reduce_line(
         %Line{numbers: line_numbers, symbols: line_symbols},
         {symbols, matrix}
       ) do
    {Enum.concat(symbols, line_symbols),
     Enum.reduce(line_numbers, matrix, &add_number_to_matrix/2)}
  end

  defp add_number_to_matrix(%Number{} = number, matrix) do
    number.x_range
    |> Enum.to_list()
    |> Enum.reduce(matrix, &add_coords_to_matrix(&1, number, &2))
  end

  defp add_coords_to_matrix(x, %Number{} = number, matrix) do
    Map.put(matrix, {x, number.y}, number)
  end

  defguard is_symbol(val) when val !== nil and val not in @digits and val !== "."

  def symbol?(val) when is_symbol(val), do: true
  def symbol?(val) when not is_symbol(val), do: false

  defp parse_line({"" <> raw, y}) do
    parse_line(
      raw,
      %Line{raw: raw, y: y},
      0,
      %{digit: "", range: nil}
    )
  end

  @type number_acc() :: %{
          digit: String.t(),
          range: Range.t() | nil
        }

  @spec parse_line(String.t(), Line.t(), integer(), number_acc()) :: Line.t()
  defp parse_line("", %Line{} = line, _idx, number_acc) do
    parse_number(line, number_acc)
  end

  for digit <- @digits do
    defp parse_line(
           <<unquote(digit), rest::binary>>,
           %Line{} = line,
           idx,
           %{} = number_acc
         ) do
      parse_line(
        rest,
        line,
        idx + 1,
        update_number_acc(number_acc, idx, unquote(digit))
      )
    end
  end

  defp parse_line(
         <<char::binary-size(1), rest::binary>>,
         %Line{} = line,
         idx,
         number_acc
       ) do
    parse_line(
      rest,
      line
      |> parse_number(number_acc)
      |> parse_symbol(char, idx),
      idx + 1,
      %{digit: "", range: nil}
    )
  end

  defp parse_symbol(%Line{} = line, ".", _) do
    line
  end

  defp parse_symbol(%Line{} = line, symbol, idx) when is_symbol(symbol) do
    %{line | symbols: [%Symbol{x: idx, y: line.y} | line.symbols]}
  end

  @spec update_number_acc(number_acc(), integer(), String.t()) :: number_acc()
  defp update_number_acc(%{digit: acc, range: nil}, idx, digit) do
    %{digit: acc <> digit, range: Range.new(idx, idx)}
  end

  defp update_number_acc(%{digit: acc, range: %Range{} = range}, idx, digit) do
    %{digit: acc <> digit, range: %{range | last: idx}}
  end

  defp parse_number(%Line{} = line, %{digit: ""}) do
    line
  end

  defp parse_number(%Line{} = line, %{range: %Range{}} = acc) do
    number = %Number{
      value: String.to_integer(acc.digit),
      x_range: acc.range,
      y: line.y
    }

    %{line | numbers: [number | line.numbers]}
  end
end

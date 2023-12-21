defmodule Aoc2023.Day6.Parser do
  def parse_file(input_type, number_parser) do
    Aoc2023.Day6
    |> Aoc2023.read_input_file(input_type)
    |> Stream.with_index()
    |> Enum.map(&parse_line(&1, number_parser))
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.into(&1, %{}))
  end

  defp parse_line({line, idx}, number_parser) do
    line
    |> String.split(": ")
    |> Enum.at(1)
    |> String.trim()
    |> apply_parser(number_parser)
    |> Enum.map(&parse_number(&1, idx))
  end

  defp parse_number(num, idx) do
    {
      label(idx),
      num
      |> String.trim()
      |> String.to_integer()
    }
  end

  defp apply_parser(number, :part_1) do
    String.split(number, ~r/\s+/)
  end

  defp apply_parser(number, :part_2) do
    number
    |> String.replace(" ", "")
    |> List.wrap()
  end

  defp label(0), do: :time
  defp label(1), do: :distance
end

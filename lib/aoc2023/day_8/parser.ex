defmodule Aoc2023.Day8.Parser do
  alias Aoc2023.Day8

  def parse_instructions(input_type) do
    :R
    :L

    [instructions] =
      Day8
      |> Aoc2023.read_input_file(input_type)
      |> Stream.reject(&empty_line?/1)
      |> Stream.reject(&node_line?/1)
      |> Enum.to_list()

    instructions
    |> String.split("", trim: true)
    |> Enum.map(&String.to_existing_atom/1)
  end

  def parse_nodes(input_type) do
    Day8
    |> Aoc2023.read_input_file(input_type)
    |> Stream.filter(&node_line?/1)
    |> Stream.map(&parse_node/1)
    |> Enum.into(%{})
  end

  defp empty_line?(""), do: true
  defp empty_line?(_), do: false

  defp node_line?(<<_node::binary-size(3), " = ", _rest::binary>>), do: true
  defp node_line?("" <> _), do: false

  defp parse_node(
         <<node::binary-size(3), " = ", "(", left::binary-size(3), ", ",
           right::binary-size(3), _::binary>>
       ) do
    {node, {left, right}}
  end
end

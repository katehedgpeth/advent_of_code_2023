defmodule Aoc2023.Day9 do
  alias __MODULE__.Node

  @doc """
  Part 1

  We are asked to write a function that can predict the next number in a
  sequence of numbers.

  Took me a long time to get the pattern matching right for the binary tree
  builder, but I eventually got there.

  iex> Aoc2023.Day9.part_1(:test)
  114

  iex> Aoc2023.Day9.part_1(:real)
  1806615041
  """
  def part_1(input_type) do
    __MODULE__
    |> Aoc2023.read_input_file(input_type)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&build_tree/1)
    |> Stream.map(&predict_next/1)
    |> Enum.reduce(0, &Kernel.+/2)
  end

  @doc """
  This time, we need to predict what number would come BEFORE the left-most node.

  Thankfully, I wrote this as nodes so I can just reverse-climb the tree from
  the other end.

  iex> Aoc2023.Day9.part_2(:real)
  1211
  """
  def part_2(input_type) do
    __MODULE__
    |> Aoc2023.read_input_file(input_type)
    |> Stream.map(&parse_line/1)
    |> Stream.map(&build_tree/1)
    |> Stream.map(&predict_history/1)
    |> Enum.reduce(0, &Kernel.+/2)
  end

  defp parse_line(line) do
    line
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  def build_tree(set) do
    set
    |> Node.init()
    |> _build_tree()
  end

  defp _build_tree(nodes) do
    nodes
    |> Enum.reject(&(&1.val == nil))
    |> Enum.all?(&(&1.val == 0))
    |> if(
      do: nodes,
      else:
        nodes
        |> Node.build_list([])
        |> _build_tree()
    )
  end

  defp predict_next(list)
       when is_list(list),
       do:
         list
         |> List.last()
         |> predict_next()

  defp predict_next(%Node{val: 0} = node),
    do: predict_next(node.right, node.left.val)

  defp predict_next(%Node{left: nil}, acc),
    do: acc

  defp predict_next(%Node{} = node, acc),
    do: predict_next(node.right, acc + node.val + node.left.val)

  defp predict_history(list) when is_list(list) do
    list
    |> List.first()
    |> predict_history(0)
  end

  defp predict_history(%Node{left: left, val: val}, acc) do
    case left do
      nil -> val - acc
      %Node{} -> predict_history(left, val - acc)
    end
  end
end

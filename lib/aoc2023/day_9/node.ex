defmodule Aoc2023.Day9.Node do
  defstruct [:left, :right, :val]
  alias __MODULE__

  @type t() :: %__MODULE__{
          left: t() | nil,
          right: t() | nil,
          val: integer()
        }

  def init(values) do
    Enum.map(values, &%__MODULE__{val: &1})
  end

  def build_list(list, []) do
    # We reverse the initial list because we are going to build
    # our output right-to-left.
    [%Node{} = first | rest] = Enum.reverse(list)

    build_list(rest, [%Node{left: first}])
  end

  def build_list(
        [%Node{} = last],
        [%Node{left: %Node{} = prev_left} | _] = acc
      ) do
    [new(%{left: last, right: prev_left}) | acc]
    |> Enum.reject(&(&1.val == nil))
  end

  def build_list(
        [%Node{left: nil, right: nil} = left | rest],
        [%Node{left: %Node{} = prev_left} | _] = acc
      ) do
    parent = new(%{left: left, right: prev_left})
    build_list(rest, [parent | acc])
  end

  def build_list(
        [%Node{left: %Node{}, right: %Node{}} = left | rest],
        [%Node{left: %Node{} = prev_left} | _] = acc
      ) do
    build_list(rest, [new(%{left: left, right: prev_left}) | acc])
  end

  def new(%{left: %Node{val: left_val} = left, right: nil}) when not is_nil(left_val) do
    %__MODULE__{left: left}
  end

  def new(%{left: %Node{} = left, right: %Node{} = right}) do
    %__MODULE__{
      left: left,
      right: right,
      val: val(left, right)
    }
  end

  defp val(%Node{val: left}, %Node{val: right})
       when not is_nil(left) and not is_nil(right),
       do: right - left

  defp val(%Node{val: left}, %Node{val: nil}) when not is_nil(left), do: nil

  def add_right([last | rest]) do
    Enum.reduce(rest, [last], &add_right/2)
  end

  defp add_right(
         %Node{left: %Node{}, right: nil} = parent,
         acc
       ) do
    %Node{left: prev_left} = List.first(acc)

    [_add_right(%{parent: parent, right: prev_left}) | acc]
  end

  defp _add_right(%{
         parent: %Node{right: nil, left: %Node{}} = parent,
         right: %Node{val: nil} = right
       }) do
    %{parent | right: right}
  end

  defp _add_right(%{
         parent: %Node{right: nil, left: %Node{val: left_val}} = parent,
         right: %Node{val: right_val} = right
       })
       when not is_nil(left_val) and not is_nil(right_val) do
    %{parent | val: right_val - left_val, right: right}
  end
end

defmodule Aoc2023.Day7.Card do
  @moduledoc """
  A hand consists of five cards, labeled one of
  A, K, Q, J, T, 9, 8, 7, 6, 5, 4, 3, or 2
  """
  @ranked_labels [?A, ?K, ?Q, ?J, ?T, Enum.to_list(?9..?2)]
                 |> List.flatten()
                 |> Enum.reverse()
                 |> Enum.with_index(1)

  defmacro card_labels() do
    quote do
      Enum.map(unquote(@ranked_labels), &elem(&1, 0))
    end
  end

  for {label, rank} <- @ranked_labels do
    def value(<<unquote(label)>>), do: unquote(rank)
  end
end

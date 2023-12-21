defmodule Aoc2023.Day7.Card do
  @moduledoc """
  A hand consists of five cards, labeled one of
  A, K, Q, J, T, 9, 8, 7, 6, 5, 4, 3, or 2.

  In part 2, Js are jokers, not jacks.
  """
  @jacks [?A, ?K, ?Q, ?J, ?T, Enum.to_list(?9..?2)]
  @jokers [?A, ?K, ?Q, ?T, Enum.to_list(?9..?2), ?J]

  @ranked_labels [true: @jokers, false: @jacks]
                 |> Enum.map(fn {jokers_wild?, list} ->
                   {jokers_wild?,
                    list
                    |> List.flatten()
                    |> Enum.map(&<<&1>>)
                    |> Enum.reverse()
                    |> Enum.with_index(1)
                    |> Map.new()}
                 end)

  def value(card, jokers_wild?) do
    @ranked_labels
    |> Keyword.fetch!(jokers_wild?)
    |> Map.fetch!(card)
  end

  def ranks(), do: @ranked_labels
end

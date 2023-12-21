defmodule Aoc2023.Day7.Parser do
  alias Aoc2023.Day7.Hand

  def parse_hand(<<hand::binary-size(5), bid::binary>>) do
    %{
      hand: hand,
      type: Hand.parse(hand),
      bid:
        bid
        |> String.trim()
        |> String.to_integer()
    }
  end
end

defmodule Aoc2023.Day7.Parser do
  alias Aoc2023.Day7.Hand

  def parse_hand(<<hand::binary-size(5), " ", bid::binary>>, jokers_wild?) do
    hand_freqs = Hand.sort_by_frequencies(hand, jokers_wild?)

    %{
      hand: hand,
      mask: Hand.parse_mask(hand_freqs),
      type: Hand.parse_type(hand_freqs),
      value: Hand.value(hand, jokers_wild?),
      bid:
        bid
        |> String.trim()
        |> String.to_integer()
    }
  end
end

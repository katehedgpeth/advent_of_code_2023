defmodule Aoc2023.Day7.Hand do
  alias Aoc2023.Day7.Card
  require Card

  @moduledoc """
  Every hand is exactly one type. From strongest to weakest, they are:

  Five of a kind: AAAAA
  Four of a kind: AA8AA
  Full house: 23332
  Three of a kind: TTT98
  Two pair: 23432
  One pair: A23A4
  High card: 23456
  """

  @type hand_type() ::
          :five_of_a_kind
          | :four_of_a_kind
          | :full_house
          | :three_of_a_kind
          | :two_pair
          | :one_pair
          | :high_card

  @type_ranks %{
    :five_of_a_kind => 7,
    :four_of_a_kind => 6,
    :full_house => 5,
    :three_of_a_kind => 4,
    :two_pair => 3,
    :one_pair => 2,
    :high_card => 1
  }

  @spec rank(hand_type()) :: 1 | 2 | 3 | 4 | 5 | 6
  def rank(type),
    do: Map.fetch!(@type_ranks, type)

  def value("" <> hand, jokers_wild?) do
    hand
    |> String.split("")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&Card.value(&1, jokers_wild?))
    |> List.to_tuple()
  end

  def higher_hand(
        <<card1::binary-size(1), rest1::binary>>,
        <<card2::binary-size(1), rest2::binary>>,
        jokers_wild?
      )
      when card1 == card2,
      do: higher_hand(rest1, rest2, jokers_wild?)

  def higher_hand(
        <<card1::binary-size(1), _::binary>>,
        <<card2::binary-size(1), _::binary>>,
        jokers_wild?
      ) do
    Card.value(card1, jokers_wild?) < Card.value(card2, jokers_wild?)
  end

  def sort_by_frequencies("" <> hand, jokers_wild?) do
    hand
    |> String.trim()
    |> String.split("")
    |> Enum.reject(&(&1 == ""))
    |> Enum.frequencies()
    |> account_for_jokers(jokers_wild?)
    |> Enum.sort_by(&sort_frequencies/1)
  end

  defp sort_frequencies({_, count}), do: count * -1

  defp account_for_jokers(cards, false), do: cards

  defp account_for_jokers(%{"J" => 5} = cards, true) do
    cards
  end

  defp account_for_jokers(cards, true) do
    case Map.pop(cards, "J") do
      {nil, _} ->
        cards

      {jokers, non_jokers} ->
        {jokers, Enum.sort_by(non_jokers, &sort_frequencies/1)}
        |> _account_for_jokers()
    end
  end

  # JAAAA -> AAAAA :five_of_a_kind
  defp _account_for_jokers({jokers, [{high, high_count}]})
       when jokers + high_count == 5 do
    %{high => 5}
  end

  # JJJAK -> AAAAK :four_of_a_kind
  # JJAAK -> AAAAK :four_of_a_kind
  # JAAAK -> AAAAK :four_of_a_kind
  defp _account_for_jokers({_, [{high, _}, {low, 1}]}) do
    %{high => 4, low => 1}
  end

  # JAAKK -> AAAKK :full_house
  defp _account_for_jokers({1, [{high, 2}, {low, 2}]}) do
    %{high => 3, low => 2}
  end

  # JJAKK -> AAAKK :full_house
  defp _account_for_jokers({2, [{high, 1}, {low, 2}]}) do
    %{high => 2, low => 3}
  end

  # JAAKQ -> AAAKQ :three_of_a_kind
  defp _account_for_jokers({1, [{high, 2}, {card, 1}, {card_, 1}]}) do
    %{high => 3, card => 1, card_ => 1}
  end

  defp _account_for_jokers({2, [{card1, 1}, {card2, 1}, {card3, 1}]}) do
    %{card1 => 3, card2 => 1, card3 => 1}
  end

  # JAKQT -> AAKQT :one_pair
  defp _account_for_jokers({1, [{card1, 1}, {card2, 1}, {card3, 1}, {card4, 1}]}) do
    %{card1 => 2, card2 => 1, card3 => 1, card4 => 1}
  end

  def parse_mask(frequencies) do
    frequencies
    |> Enum.flat_map(&_parse_mask/1)
    |> Enum.join("")
  end

  defp _parse_mask({char, count}) do
    for _ <- 1..count do
      char
    end
  end

  def parse_type([{_, 5}]), do: :five_of_a_kind
  def parse_type([{_, 4}, {_, 1}]), do: :four_of_a_kind
  def parse_type([{_, 3}, {_, 2}]), do: :full_house
  def parse_type([{_, 3}, {_, 1}, {_, 1}]), do: :three_of_a_kind
  def parse_type([{_, 2}, {_, 2}, {_, 1}]), do: :two_pair
  def parse_type([{_, 2}, {_, 1}, {_, 1}, {_, 1}]), do: :one_pair
  def parse_type([{_, 1}, {_, 1}, {_, 1}, {_, 1}, {_, 1}]), do: :high_card
end

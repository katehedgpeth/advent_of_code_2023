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

  def higher_hand(
        <<card1::binary-size(1), rest1::binary>>,
        <<card2::binary-size(1), rest2::binary>>
      )
      when card1 == card2,
      do: higher_hand(rest1, rest2)

  def higher_hand(
        <<card1::binary-size(1), _::binary>>,
        <<card2::binary-size(1), _::binary>>
      ) do
    Card.value(card1) < Card.value(card2)
  end

  @spec parse(String.t()) :: hand_type()

  def parse("" <> hand) do
    hand
    |> String.trim()
    |> String.split("")
    |> Enum.reject(&(&1 == ""))
    |> Enum.group_by(& &1)
    |> _parse()
  end

  defp _parse(split) when map_size(split) == 5 do
    :high_card
  end

  defp _parse(split) when map_size(split) == 4 do
    :one_pair
  end

  for char <- Card.card_labels() do
    defp _parse(%{<<unquote(char)>> => five}) when length(five) == 5 do
      :five_of_a_kind
    end

    defp _parse(%{<<unquote(char)>> => four}) when length(four) == 4 do
      :four_of_a_kind
    end
  end

  defp _parse(%{} = hand),
    do:
      hand
      |> Enum.to_list()
      |> _parse()

  defp _parse([{_, [one, one, one]}, {_, [two, two]}]), do: :full_house
  defp _parse([{_, [one, one]}, {_, [two, two, two]}]), do: :full_house

  defp _parse([{_, [same, same, same]}, {_, [_]}, {_, [_]}]), do: :three_of_a_kind
  defp _parse([{_, [_]}, {_, [same, same, same]}, {_, [_]}]), do: :three_of_a_kind
  defp _parse([{_, [_]}, {_, [_]}, {_, [same, same, same]}]), do: :three_of_a_kind

  defp _parse([{_, [_]}, {_, [one, one]}, {_, [two, two]}]), do: :two_pair
  defp _parse([{_, [one, one]}, {_, [_]}, {_, [two, two]}]), do: :two_pair
  defp _parse([{_, [one, one]}, {_, [two, two]}, {_, [_]}]), do: :two_pair
end

defmodule Aoc2023.Day1 do
  @moduledoc """
  Day 1
  https://adventofcode.com/2023/day/1
  """
  @doc """
  Part 1:

  ```
  On each line, the calibration value can be found by combining the first digit
  and the last digit (in that order) to form a single two-digit number.

  What is the sum of all of the calibration values?
  ```

  Basic strategy: read each line forwards and backwards, stopping when we reach
  the first digit from each direction. Concat the two returned strings, parse
  into an integer, then reduce to add all the lines.

      iex> Aoc2023.Day1.part_1(:test)
      142

      iex> Aoc2023.Day1.part_1(:real)
      55123
  """
  def part_1(file_type) do
    __MODULE__
    |> Aoc2023.read_input_file(file_name(file_type, 1))
    |> Stream.map(&parse_line/1)
    |> Enum.reduce(0, &Kernel.+/2)
  end

  @doc """
  Part 2:

  ```
  Your calculation isn't quite right. It looks like some of the digits are
  actually spelled out with letters: one, two, three, four, five, six, seven,
  eight, and nine also count as valid "digits".

  What is the sum of all of the calibration values?
  ```

  Basic strategy: read each line forwards and backwards again, but this time keep
  an accumulator when reading backwards whenever we encounter a non-digit character.
  If the string or accumulator is a number name, return the digit it represents.
  Then proceed as in part 1.

      iex> Aoc2023.Day1.part_2(:test)
      281

      iex> Aoc2023.Day1.part_2(:real)
      55260
  """

  def part_2(file_type) do
    __MODULE__
    |> Aoc2023.read_input_file(file_name(file_type, 2))
    |> Stream.map(&parse_line_with_words/1)
    |> Enum.into([])
    |> Enum.reduce(0, &Kernel.+/2)
  end

  #########################################################

  #

  #

  #

  #########################################################
  #########################################################
  ##
  ##  PRIVATE METHODS
  ##
  #########################################################

  defp file_name(:real, _part) do
    :real
  end

  defp file_name(:test, part) do
    :"part#{part}_test"
  end

  defp parse_line("" <> line) do
    [
      first_num(line),
      last_num(line)
    ]
    |> Enum.join("")
    |> String.to_integer()
  end

  defp first_num(line), do: get_num(line, :+, 0)
  defp last_num(line), do: get_num(line, :-, String.length(line) - 1)

  @spec get_num(String.t(), :+ | :-, integer()) :: String.t()
  defp get_num("" <> line, advancer, idx) do
    char =
      String.at(line, idx)

    if char == nil do
      raise "No character found at index #{idx} in #{line}"
    end

    case get_digit(char) do
      {:ok, digit} ->
        digit

      :error ->
        get_num(line, advancer, apply(Kernel, advancer, [idx, 1]))
    end
  end

  defp parse_line_with_words(line) do
    try do
      line
      |> first_num_or_word()
      |> Kernel.<>(last_num_or_word(line))
      |> String.to_integer(10)
    rescue
      error ->
        raise """
        line: #{line}
        error: #{inspect(error)}
        """
    end
  end

  @number_names %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9",
    "zero" => "0"
  }

  for digit <- Map.values(@number_names) do
    defp get_digit(<<unquote(digit)>>), do: {:ok, unquote(digit)}
    defp get_digit(<<unquote(digit), _::binary>>), do: {:ok, unquote(digit)}
  end

  for {name, digit} <- @number_names do
    defp get_digit(<<unquote(name)>>), do: {:ok, unquote(digit)}
    defp get_digit(<<unquote(name), _::binary>>), do: {:ok, unquote(digit)}
  end

  defp get_digit(_), do: :error

  defp first_num_or_word(line) do
    case get_digit(line) do
      {:ok, digit} ->
        digit

      :error ->
        {_, rest} = String.split_at(line, 1)

        if rest == "" do
          raise "no first_number found in #{line}"
        end

        first_num_or_word(rest)
    end
  end

  defp last_num_or_word(line) do
    last_num_or_word(line, "", String.length(line) - 1)
  end

  defp last_num_or_word(line, acc, idx) do
    case get_digit(acc) do
      {:ok, digit} ->
        digit

      :error ->
        do_last_num_or_word(line, acc, idx)
    end
  end

  defp do_last_num_or_word(line, acc, idx) do
    case idx do
      0 ->
        last_num_or_word(line, line, idx - 1)

      -1 ->
        raise "No last_number found in #{line}"

      _ ->
        {rest, char} = String.split_at(line, idx)

        last_num_or_word(rest, char <> acc, idx - 1)
    end
  end
end

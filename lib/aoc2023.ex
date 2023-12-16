defmodule Aoc2023 do
  @moduledoc """
  Documentation for `Aoc2023`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Aoc2023.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  Reads a file and splits it into lines. (splitter defaults to "\n")
  Uses Module.underscore/1 to generate file path based on module name,
  so folders in priv should not use underscores before numbers - i.e.,
  Aoc2023.Day1 files should be put in "priv/day1/*"

  ## Examples
      iex> Aoc2023.read_input_file(Aoc2023.Day1, :part1_test) |> Enum.into([])
      [ "1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet" ]
  """

  def read_input_file(module, input_type, _splitter \\ "\n") do
    :aoc_2023
    |> :code.priv_dir()
    |> Path.join(input_file_name(module, input_type))
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end

  @doc """
  Builds the path to a file based on a module name.

  ## Examples
      iex> Aoc2023.input_file_name(Aoc2023.Day1, :test)
      "day1/test_input.txt"
  """
  @spec input_file_name(module(), :test | :real) :: String.t()
  def input_file_name(module, input_type) do
    [_ | child_module] = Module.split(module)

    child_module
    |> Module.concat()
    |> Macro.underscore()
    |> Path.join("#{input_type}_input.txt")
  end
end

defmodule Aoc2023.Day8.Agent do
  use Agent
  alias Aoc2023.Day8.Parser

  defstruct [:instructions, :nodes]

  @type nodes() :: %{String.t() => {String.t(), String.t()}}
  @type instructions() :: list(:L | :R)

  @type t() :: %__MODULE__{
          instructions: instructions(),
          nodes: nodes()
        }

  def start_link(opts) do
    Agent.start_link(fn -> init(opts) end, name: __MODULE__)
  end

  def get_instruction(idx) do
    Agent.get(__MODULE__, &_get_instruction(&1, idx))
  end

  def get_node("" <> name) do
    Agent.get(__MODULE__, &_get_node(&1, name))
  end

  defp _get_node(%{nodes: nodes}, name), do: Map.fetch!(nodes, name)

  defp _get_instruction(%{instructions: instructions}, idx)
       when idx == length(instructions) do
    _get_instruction(%{instructions: instructions}, 0)
  end

  defp _get_instruction(%{instructions: instructions}, idx) do
    case Enum.at(instructions, idx) do
      nil -> raise "no value exists at index #{idx} in #{inspect(instructions)}"
      instr -> {instr, idx + 1}
    end
  end

  defp init(input_type: input_type) do
    %{
      instructions: Parser.parse_instructions(input_type),
      nodes: Parser.parse_nodes(input_type)
    }
  end
end

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
    Agent.start_link(fn -> init(opts) end)
  end

  def get_A_keys(agent) do
    Agent.get(agent, &_get_A_keys/1)
  end

  def get_instruction(agent, idx) do
    Agent.get(agent, &_get_instruction(&1, idx))
  end

  def get_node(agent, "" <> key) do
    Agent.get(agent, &_get_node(&1, key))
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

  defp _get_A_keys(%{nodes: nodes}) do
    nodes
    |> Map.keys()
    |> Enum.filter(&(String.at(&1, 2) == "A"))
  end

  defp init(input_type: input_type) do
    %{
      instructions: Parser.parse_instructions(input_type),
      nodes: Parser.parse_nodes(input_type)
    }
  end
end

defmodule Aoc2023.Day5.Mapper do
  @enforce_keys [:src, :dest, :range]
  defstruct [:src, :dest, :range]

  @type t() :: %__MODULE__{
          src: integer(),
          dest: integer(),
          range: integer()
        }

  @type option() :: {:src, integer()} | {:dest, integer()} | {:range, integer()}
  @spec new(Keyword.t(option())) :: t()
  def new(data) when is_list(data) do
    struct!(__MODULE__, data)
  end

  @type range_tuple() :: {start :: integer(), finish :: integer()}
  @type set() :: MapSet.t({range_tuple(), t()})

  @doc """
  Inserts a mapper into a list of mappers, keeping them sorted
  by range.
  """
  @spec insert(set(), t()) :: set()
  def insert(%MapSet{} = set, %__MODULE__{} = new) do
    MapSet.put(set, {{new.src, new.src + new.range}, new})
  end

  defmacro range_start(tuple) do
    quote do
      unquote(tuple)
      |> elem(0)
      |> elem(0)
    end
  end

  defmacro range_end(tuple) do
    quote do
      unquote(tuple)
      |> elem(0)
      |> elem(1)
    end
  end

  defguard is_in_range(range_tuple, integer)
           when integer >= range_start(range_tuple) and integer <= range_end(range_tuple)

  @spec find(integer(), set()) :: {:ok, t()} | :not_found
  def find(integer, mappers) when is_integer(integer) do
    case Enum.find(mappers, &is_in_range(&1, integer)) do
      nil -> :not_found
      {_, %__MODULE__{} = mapper} -> {:ok, mapper}
    end
  end

  def map(integer, mappers) do
    case find(integer, mappers) do
      {:ok, %__MODULE__{} = mapper} -> do_map(integer, mapper)
      :not_found -> integer
    end
  end

  defp do_map(integer, %__MODULE__{} = mapper) do
    mapper.dest - mapper.src + integer
  end
end

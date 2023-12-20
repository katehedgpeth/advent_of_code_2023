defmodule Aoc2023.Day5.Mapper do
  @enforce_keys [:src, :dest, :range]
  defstruct [:src, :dest, :range, :diff]

  @type t() :: %__MODULE__{
          src: integer(),
          dest: integer(),
          range: integer(),
          diff: integer()
        }

  @type option() :: {:src, integer()} | {:dest, integer()} | {:range, integer()}
  @spec new(Keyword.t(option())) :: t()
  def new(data) when is_list(data) do
    %{dest: dest, src: src} = Enum.into(data, %{})

    __MODULE__
    |> struct(data)
    |> Map.replace!(:diff, dest - src)
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

  def is_in_src_range({{first, last}, _}, integer) do
    integer >= first and integer < last
  end

  def is_in_dest_range({_, %__MODULE__{diff: diff}} = mapper, integer) do
    is_in_src_range(mapper, integer - diff)
  end

  @spec find(integer(), set()) :: {:ok, t()} | :not_found
  def find(integer, mappers) do
    _find(integer, mappers, :is_in_src_range)
  end

  def reverse_find(integer, mappers) do
    _find(integer, mappers, :is_in_dest_range)
  end

  defp _find(integer, mappers, test_fn) when is_integer(integer) do
    case Enum.find(mappers, &apply(__MODULE__, test_fn, [&1, integer])) do
      nil -> :not_found
      {_, %__MODULE__{} = mapper} -> {:ok, mapper}
    end
  end

  def source?({{source, _dest}, _mapper}, seeking), do: source == seeking

  def map(integer, mappers),
    do: _map(integer, mappers, &Kernel.+/2, &find/2)

  @spec reverse_map(integer(), set()) :: integer()
  def reverse_map(integer, mappers),
    do: _map(integer, mappers, &Kernel.-/2, &reverse_find/2)

  def _map(integer, mappers, add_or_subtract, find_fn) do
    case find_fn.(integer, mappers) do
      {:ok, %__MODULE__{diff: diff}} ->
        add_or_subtract.(integer, diff)

      :not_found ->
        integer
    end
  end
end

defmodule Aoc2023.Day5.Parser do
  alias Aoc2023.{
    Day5,
    Day5.State
  }

  @categories State
              |> struct([])
              |> Map.fetch!(:mappers)
              |> Map.keys()

  @category_strings Enum.map(
                      @categories,
                      fn category ->
                        category
                        |> Tuple.to_list()
                        |> Enum.map(&Atom.to_string/1)
                        |> Enum.join("-to-")
                      end
                    )

  def parse_seed_ids(%State{} = state) do
    state
    |> read_file()
    |> Stream.filter(&seed_ids_line?/1)
    |> Enum.to_list()
    |> do_parse_seed_ids(state.seed_id_type)
  end

  defp do_parse_seed_ids(["seeds: " <> seed_ids], type) do
    seed_ids
    |> String.split("\s")
    |> Enum.map(&String.to_integer/1)
    |> maybe_seed_id_range(type)
  end

  defp maybe_seed_id_range(seed_ids, :integer) do
    seed_ids
  end

  defp maybe_seed_id_range(seed_ids, :range) do
    seed_ids_to_ranges(seed_ids)
  end

  def seed_ids_to_ranges(seed_ids) do
    seed_ids
    |> Enum.chunk_every(2)
    |> MapSet.new(&seed_id_range/1)
    |> Enum.to_list()
  end

  defp seed_id_range([first, range]) do
    Range.new(first, first + range - 1)
  end

  def start_mappers(%State{} = state) do
    state
    |> read_file()
    |> Stream.with_index()
    |> Stream.filter(&mapper_line?/1)
    |> Stream.map(&send_mapper_idx_msg/1)
    |> start_mapper_tasks(state)
    |> Stream.run()
  end

  def parse_category_line_ranges(%State{} = state) do
    state
    |> read_file()
    |> Stream.with_index()
    |> Stream.filter(&category_line?/1)
    |> Enum.reduce(state, &parse_category_line_range/2)
  end

  @spec parse_category_line_range({String.t(), integer()}, State.t()) :: State.t()
  defp parse_category_line_range(
         {"" <> category, idx},
         %State{} = state
       ) do
    [
      source,
      destination
    ] =
      category
      |> String.replace(" map:", "")
      |> String.split("-to-")
      |> Enum.map(&String.to_existing_atom/1)

    State.add_category_line_range(state, {source, destination}, Range.new(idx, 1_000_000))
  end

  def parse_mapper({"" <> line, line_num}, state, self_) do
    %{range: range, src: src, dest: dest} =
      parse_mapper_string(line)

    category =
      get_category_for_mapper(state.category_line_ranges, line_num)

    send(
      self_,
      {:add_mapper_to_state,
       %{
         range: range,
         src: src,
         dest: dest,
         category: category,
         line: line_num
       }}
    )
  end

  defp parse_mapper_string(string) do
    split =
      string
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

    [:dest, :src, :range]
    |> Enum.zip(split)
    |> Enum.into(%{})
  end

  defp read_file(%State{input_type: input_type}) do
    Aoc2023.read_input_file(Day5, input_type)
  end

  defp get_category_for_mapper(ranges, line_num) do
    {_, _} =
      ranges
      |> Enum.find(&line_category?(&1, line_num))
      |> elem(0)
  end

  defp line_category?({_, %Range{} = range}, line_num) do
    line_num > range.first and line_num < range.last
  end

  defp empty_line?({line, _}), do: empty_line?(line)
  defp empty_line?(""), do: true
  defp empty_line?("" <> _), do: false

  defp mapper_line?(line) do
    not category_line?(line) and not seed_ids_line?(line) and not empty_line?(line)
  end

  defp seed_ids_line?({line, _}), do: seed_ids_line?(line)
  defp seed_ids_line?("seeds: " <> _), do: true
  defp seed_ids_line?("" <> _), do: false

  defp category_line?({line, _}), do: category_line?(line)

  for category <- @category_strings do
    defp category_line?(unquote(category) <> _), do: true
  end

  defp category_line?("" <> _), do: false

  @type line_with_index() :: {String.t(), integer()}

  @spec send_mapper_idx_msg(line_with_index()) :: line_with_index()
  defp send_mapper_idx_msg(line) do
    self()
    |> send({:add_mapper_idx_to_state, line})
    |> elem(1)
  end

  defp start_mapper_tasks(stream, state) do
    Task.Supervisor.async_stream_nolink(
      Aoc2023.TaskSupervisor,
      stream,
      __MODULE__,
      :parse_mapper,
      [state, self()]
    )
  end
end

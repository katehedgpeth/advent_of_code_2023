defmodule Aoc2023.Day5.Agent do
  use GenServer

  alias Aoc2023.Day5.Parser
  alias Aoc2023.Day5.State

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    send(self(), :await_tasks)
    {:ok, State.new(opts), {:continue, :parse_file}}
  end

  def handle_continue(:parse_file, state) do
    send(self(), :save_seed_ids)
    {:noreply, state, {:continue, :get_categories}}
  end

  def handle_continue(:get_categories, state) do
    {
      :noreply,
      Parser.parse_category_line_ranges(state),
      {:continue, :update_category_ranges}
    }
  end

  def handle_continue(:update_category_ranges, state) do
    {
      :noreply,
      State.update_category_line_ranges(state),
      {:continue, :parse_mappers}
    }
  end

  def handle_continue(:parse_mappers, state) do
    Parser.start_mappers(state)
    {:noreply, state}
  end

  def handle_info(:await_tasks, %State{} = state) do
    if State.finished_parsing?(state),
      do: GenServer.reply(state.parent, state),
      else: send(self(), :await_tasks)

    {:noreply, state}
  end

  def handle_info(:save_seed_ids, state) do
    {:noreply,
     state
     |> Parser.parse_seed_ids()
     |> State.save_seed_ids(state)}
  end

  def handle_info({:add_mapper_idx_to_state, line}, state) do
    {:noreply, State.add_mapper_idx_to_state(line, state)}
  end

  def handle_info({:add_mapper_to_state, info}, state) do
    {:noreply, State.save_mapper_to_state(state, info)}
  end

  def handle_call(:state, from, state) do
    if State.finished_parsing?(state) do
      {:reply, state, state}
    else
      {:noreply, State.set_parent(state, from)}
    end
  end

  def set(pid, key, val) do
    Agent.update(pid, &Map.put(&1, key, val))
  end

  def update!(pid, key, callback) when is_function(callback) do
    Agent.update(pid, &Map.update!(&1, key, callback))
  end

  def get_state(pid) do
    GenServer.call(pid, :state)
  end

  def get(pid, key) do
    Agent.get(pid, &Map.get(&1, key))
  end

  def fetch!(pid, key) do
    Agent.get(pid, &Map.fetch!(&1, key))
  end
end

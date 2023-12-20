defmodule Aoc2023.Day5Test do
  use ExUnit.Case, async: true

  alias Aoc2023.{
    Day5,
    Day5.Agent,
    Day5.MapChain
  }

  test "overlaps" do
    assert Day5.find_overlaps(:test) == []
    assert Day5.find_overlaps(:real) == []
  end

  describe "MapChain" do
    for type <- [:integer, :range] do
      quote do
        setup %{seed_id_type: seed_id_type} do
          {:ok, agent} = Agent.start_link(input_type: :test, seed_id_type: unquote(type))
          _ = Agent.state(agent)
          %{agent: agent, seeds_to_locations: [{79, 82}, {14, 43}, {55, 86}, {13, 35}]}
        end

        test "seed_id_to_location/2 -- #{unquote(type)}", %{
          agent: agent,
          seeds_to_locations: seeds_to_locations
        } do
          for {seed_id, location_id} <- seeds_to_locations do
            assert MapChain.seed_id_to_location_id!(seed_id, agent) == location_id
          end
        end

        test "location_id_to_seed_id/2 -- #{unquote(type)}", %{
          agent: agent,
          seeds_to_locations: seeds_to_locations
        } do
          for {seed_id, location_id} <- seeds_to_locations do
            assert MapChain.location_id_to_seed_id(location_id, agent) == {:ok, seed_id}
          end
        end
      end
    end
  end
end

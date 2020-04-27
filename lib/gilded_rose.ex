defmodule GildedRose do
  use Agent
  alias GildedRose.Item

  defmodule BaseItem do
    defstruct [:item]
  end

  defmodule LegendaryItem do
    defstruct [:item]
  end

  defmodule AgingItem do
    defstruct [:item]
  end

  defmodule BackstageItem do
    defstruct [:item]
  end

  def new() do
    {:ok, agent} =
      Agent.start_link(fn ->
        [
          Item.new("+5 Dexterity Vest", 10, 20),
          Item.new("Aged Brie", 2, 0),
          Item.new("Elixir of the Mongoose", 5, 7),
          Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
          Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
          Item.new("Conjured Mana Cake", 3, 6)
        ]
      end)

    agent
  end

  def items(agent), do: Agent.get(agent, & &1)

  def to_qualified_item(item) do
    case item do
      %{name: "Sulfuras, Hand of Ragnaros"} -> struct(LegendaryItem, item: item)
      %{name: "Aged Brie"} -> struct(AgingItem, item: item)
      %{name: "Backstage passes to a TAFKAL80ETC concert"} -> struct(BackstageItem, item: item)
      item -> struct(BaseItem, item: item)
    end
  end

  def update_quality(%Item{} = item) do
    item
    |> to_qualified_item()
    |> Qualifiable.update_quality()
    |> Map.get(:item)
  end

  def update_quality(agent) do
    for i <- 0..(Agent.get(agent, &length/1) - 1) do
      item =
        agent
        |> Agent.get(&Enum.at(&1, i))
        |> update_quality()

      Agent.update(agent, &List.replace_at(&1, i, item))
    end

    :ok
  end
end

defmodule GildedRoseTest do
  use ExUnit.Case
  doctest GildedRose
  alias GildedRose.Item

  describe "update_quality/1" do
    test "it decreases the quality of items by 1" do
      {:ok, agent} =
        Agent.start_link(fn ->
          [Item.new("+5 Dexterity Vest", 10, 20)]
        end)

      GildedRose.update_quality(agent)
      [item] = GildedRose.items(agent)

      assert item.quality == 19
    end

    test "it decreases the sell_in of items by 1" do
      {:ok, agent} =
        Agent.start_link(fn ->
          [Item.new("+5 Dexterity Vest", 10, 20)]
        end)

      GildedRose.update_quality(agent)
      [item] = GildedRose.items(agent)

      assert item.sell_in == 9
    end

    test "it decreases the quality of items by 2 when sell_in is 0" do
      {:ok, agent} =
        Agent.start_link(fn ->
          [Item.new("+5 Dexterity Vest", 0, 20)]
        end)

      GildedRose.update_quality(agent)
      [item] = GildedRose.items(agent)

      assert item.quality == 18
    end

    test "quality can never be negative" do
      {:ok, agent} =
        Agent.start_link(fn ->
          [Item.new("+5 Dexterity Vest", 10, 0)]
        end)

      GildedRose.update_quality(agent)
      [item] = GildedRose.items(agent)

      assert item.quality == 0
    end

    test "brie gains quality" do
      {:ok, agent} =
        Agent.start_link(fn ->
          [Item.new("Aged Brie", 2, 0)]
        end)

      GildedRose.update_quality(agent)
      [item] = GildedRose.items(agent)

      assert item.quality == 1
    end

    test "quality is never more than 50" do
      {:ok, agent} =
        Agent.start_link(fn ->
          [
            Item.new("Aged Brie", 2, 50)
          ]
        end)

      GildedRose.update_quality(agent)
      [item] = GildedRose.items(agent)

      assert item.quality == 50
    end

    test "legendary items never drop quality or sold_in" do
      {:ok, agent} =
        Agent.start_link(fn ->
          [
            Item.new("Sulfuras, Hand of Ragnaros", 0, 80)
          ]
        end)

      GildedRose.update_quality(agent)
      [item] = GildedRose.items(agent)

      assert item.quality == 80
      assert item.sell_in == 0
    end

    test "conjured items drop twice as fast" do
      {:ok, agent} =
        Agent.start_link(fn ->
          [
            Item.new("Conjured Mana Cake", 10, 20)
          ]
        end)

      GildedRose.update_quality(agent)
      [item] = GildedRose.items(agent)

      assert item.quality == 18
      assert item.sell_in == 9
    end
  end

  describe "update_quality/1 backstage passes exceptions" do
    test "increases quality like brie" do
      {:ok, agent} =
        Agent.start_link(fn ->
          [
            Item.new("Backstage passes to a TAFKAL80ETC concert", 11, 20)
          ]
        end)

      GildedRose.update_quality(agent)
      [item] = GildedRose.items(agent)

      assert item.quality == 21
    end

    test "when there are 10 days or less, quality increase by 2" do
      {:ok, agent} =
        Agent.start_link(fn ->
          [
            Item.new("Backstage passes to a TAFKAL80ETC concert", 10, 20)
          ]
        end)

      GildedRose.update_quality(agent)
      [item] = GildedRose.items(agent)

      assert item.quality == 22
    end

    test "when there are 5 days or less, quality increase by 3" do
      {:ok, agent} =
        Agent.start_link(fn ->
          [
            Item.new("Backstage passes to a TAFKAL80ETC concert", 5, 20)
          ]
        end)

      GildedRose.update_quality(agent)
      [item] = GildedRose.items(agent)

      assert item.quality == 23
    end

    test "when sell_in is 0, quality is 0" do
      {:ok, agent} =
        Agent.start_link(fn ->
          [
            Item.new("Backstage passes to a TAFKAL80ETC concert", 0, 20)
          ]
        end)

      GildedRose.update_quality(agent)
      [item] = GildedRose.items(agent)

      assert item.quality == 0
    end
  end

  test "interface specification" do
    gilded_rose = GildedRose.new()
    [%GildedRose.Item{} | _] = GildedRose.items(gilded_rose)
    assert :ok == GildedRose.update_quality(gilded_rose)
  end
end

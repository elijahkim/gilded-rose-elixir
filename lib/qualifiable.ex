defprotocol Qualifiable do
  @fallback_to_any true
  def update_quality(item)
end

defimpl Qualifiable, for: GildedRose.LegendaryItem do
  def update_quality(item) do
    item
  end
end

defimpl Qualifiable, for: GildedRose.AgingItem do
  def update_quality(%{item: %{sell_in: 0}} = item) do
    item
  end

  def update_quality(%{item: %{sell_in: sell_in, quality: 50} = item}) do
    struct(@for, item: %{item | sell_in: sell_in - 1})
  end

  def update_quality(%{item: %{sell_in: sell_in, quality: quality} = item}) do
    struct(@for, item: %{item | sell_in: sell_in - 1, quality: quality + 1})
  end
end

defimpl Qualifiable, for: GildedRose.BackstageItem do
  def update_quality(%{item: %{sell_in: 0} = item}) do
    struct(@for, item: %{item | quality: 0})
  end

  def update_quality(%{item: %{sell_in: sell_in, quality: quality} = item}) when quality > 50 do
    struct(@for, item: %{item | sell_in: sell_in - 1})
  end

  def update_quality(%{item: %{sell_in: sell_in, quality: quality} = item}) when sell_in <= 5 do
    struct(@for, item: %{item | sell_in: sell_in - 1, quality: min(quality + 3, 50)})
  end

  def update_quality(%{item: %{sell_in: sell_in, quality: quality} = item}) when sell_in <= 10 do
    struct(@for, item: %{item | sell_in: sell_in - 1, quality: min(quality + 2, 50)})
  end

  def update_quality(%{item: %{sell_in: sell_in, quality: quality} = item}) do
    struct(@for, item: %{item | sell_in: sell_in - 1, quality: quality + 1})
  end
end

defimpl Qualifiable, for: GildedRose.BaseItem do
  def update_quality(%{item: %{sell_in: sell_in, quality: 0} = item}) do
    struct(@for, item: %{item | sell_in: sell_in - 1, quality: 0})
  end

  def update_quality(%{item: %{sell_in: 0, quality: quality} = item}) when quality <= 2 do
    struct(@for, item: %{item | sell_in: 0, quality: 0})
  end

  def update_quality(%{item: %{sell_in: 0, quality: quality} = item}) do
    struct(@for, item: %{item | sell_in: 0, quality: quality - 2})
  end

  def update_quality(%{item: %{sell_in: sell_in, quality: quality} = item}) do
    struct(@for, item: %{item | sell_in: sell_in - 1, quality: quality - 1})
  end
end

defimpl Qualifiable, for: GildedRose.ConjuredItem do
  def update_quality(%{item: %{sell_in: sell_in, quality: quality} = item}) do
    struct(@for, item: %{item | sell_in: max(sell_in - 1, 0), quality: max(quality - 2, 0)})
  end
end

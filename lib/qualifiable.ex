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

  def update_quality(%{item: %{sell_in: sell_in, quality: 50} = item}) do
    struct(@for, item: %{item | sell_in: sell_in - 1})
  end

  def update_quality(%{item: %{sell_in: sell_in, quality: quality} = item}) when sell_in <= 5 do
    struct(@for, item: %{item | sell_in: sell_in - 1, quality: quality + 3})
  end

  def update_quality(%{item: %{sell_in: sell_in, quality: quality} = item}) when sell_in <= 10 do
    struct(@for, item: %{item | sell_in: sell_in - 1, quality: quality + 2})
  end

  def update_quality(%{item: %{sell_in: sell_in, quality: quality} = item}) do
    struct(@for, item: %{item | sell_in: sell_in - 1, quality: quality + 1})
  end
end

defimpl Qualifiable, for: Any do
  def update_quality(%struct{item: item}) do
    item =
      if item.quality > 0 do
        %{item | quality: item.quality - 1}
      else
        item
      end

    item = %{item | sell_in: item.sell_in - 1}

    item =
      cond do
        item.sell_in < 0 ->
          cond do
            item.quality > 0 ->
              %{item | quality: item.quality - 1}

            true ->
              item
          end

        true ->
          item
      end

    struct(struct, item: item)
  end
end

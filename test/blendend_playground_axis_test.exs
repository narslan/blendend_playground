defmodule BlendendPlayground.AxisTest do
  use ExUnit.Case, async: true

  alias BlendendPlayground.Axis

  test "ticks for linear scales use nice steps" do
    scale = Scale.Linear.new(domain: [0, 10], range: [0, 100])

    ticks = Axis.ticks(scale, tick_count: 5)

    assert Enum.map(ticks, & &1.value) == [0.0, 2.0, 4.0, 6.0, 8.0, 10.0]
    assert Enum.map(ticks, & &1.position) == [0.0, 20.0, 40.0, 60.0, 80.0, 100.0]
  end

  test "ticks for band scales are centered by default" do
    scale = Scale.Band.new(domain: [:a, :b], range: [0, 100])

    ticks = Axis.ticks(scale)

    assert Enum.map(ticks, & &1.value) == [:a, :b]
    assert Enum.map(ticks, & &1.position) == [25.0, 75.0]
    assert Enum.map(ticks, & &1.label) == ["a", "b"]
  end
end

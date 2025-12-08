defmodule BlendendPlayground.CalculationTest do
  use ExUnit.Case, async: true

  alias BlendendPlayground.Calculation

  test "map rescales values across ranges" do
    assert Calculation.map(5, 0, 10, 0, 100) == 50.0
    assert Calculation.map(-5, -10, 0, 0, 1) == 0.5
  end

  test "norm reduces to 0..1" do
    assert Calculation.norm(5, 0, 10) == 0.5
  end

  test "lerp interpolates linearly" do
    assert Calculation.lerp(0, 10, 0.25) == 2.5
  end

  test "sq, sqrt helpers" do
    assert Calculation.sq(-3) == 9
    assert_in_delta Calculation.sqrt(9), 3.0, 1.0e-10
  end

  test "rand_radian spans -pi..pi" do
    :rand.seed(:exsplus, {1, 2, 3})
    expected = (:rand.uniform() * 2 - 1) * :math.pi()
    :rand.seed(:exsplus, {1, 2, 3})

    assert_in_delta Calculation.rand_radian(), expected, 1.0e-12
    assert expected >= -:math.pi() and expected <= :math.pi()
  end

  test "macros delegate to the functional api" do
    require BlendendPlayground.Calculation.Macros

    assert BlendendPlayground.Calculation.Macros.lerp(2, 6, 0.5) == 4.0
    assert BlendendPlayground.Calculation.Macros.norm(25, 0, 100) == 0.25
    assert BlendendPlayground.Calculation.Macros.map(5, 0, 5, 10, 20) == 20.0
    assert BlendendPlayground.Calculation.Macros.sq(4) == 16
    assert_in_delta BlendendPlayground.Calculation.Macros.sqrt(16), 4.0, 1.0e-10
    :rand.seed(:exsplus, {1, 2, 3})
    expected = (:rand.uniform() * 2 - 1) * :math.pi()
    :rand.seed(:exsplus, {1, 2, 3})
    assert_in_delta BlendendPlayground.Calculation.Macros.rand_radian(), expected, 1.0e-12
  end

  test "map rejects zero-length input ranges" do
    assert_raise ArgumentError, fn -> Calculation.map(1, 2, 2, 0, 1) end
  end
end

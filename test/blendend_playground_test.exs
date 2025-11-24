defmodule BlendendPlaygroundTest do
  use ExUnit.Case
  doctest BlendendPlayground

  test "greets the world" do
    assert BlendendPlayground.hello() == :world
  end
end

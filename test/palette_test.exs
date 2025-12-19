defmodule BlendendPlayground.PaletteTest do
  use ExUnit.Case, async: true

  alias BlendendPlayground.Palette

  describe "from_hex_list_rgb/1" do
    test "returns RGB tuples for each hex" do
      colors = Palette.from_hex_list_rgb(["#ffffff", "#9da3a4", "#ffdbda", "#000000"])

      assert length(colors) == 4
      assert Enum.all?(colors, fn
               {r, g, b} ->
                 Enum.all?([r, g, b], &is_integer/1)

               _ ->
                 false
             end)
    end
  end
end

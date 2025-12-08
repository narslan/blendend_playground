defmodule BlendendPlayground.PaletteTest do
  use ExUnit.Case, async: true

  alias BlendendPlayground.Palette

  describe "from_hex_list/1" do
    test "returns color resources for each hex" do
      colors = Palette.from_hex_list(["#ffffff", "#9da3a4", "#ffdbda", "#000000"])

      assert length(colors) == 4
      assert Enum.all?(colors, &is_reference/1)
    end
  end
end

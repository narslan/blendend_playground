defmodule BlendendPlayground.FontsTest do
  use ExUnit.Case, async: false

  alias BlendendPlayground.Fonts

  setup do
    case start_supervised(Fonts) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
      other -> raise "could not start Fonts: #{inspect(other)}"
    end

    :ok
  end

  test "lists fonts with variations" do
    fonts = Fonts.all()

    assert is_list(fonts)
    refute fonts == []
    assert Enum.all?(fonts, fn font -> is_list(font.variations) end)
  end

  test "lookup returns a variation with path" do
    [font | _] = Fonts.all()
    [variation | _] = font.variations

    assert {:ok, found} = Fonts.lookup(font.id, variation.style)
    assert is_binary(found.path)
    assert File.exists?(found.absolute_path)
  end

  test "picks up additional font paths" do
    tmp_dir = Path.join(System.tmp_dir!(), "blendend_fonts_test_#{System.unique_integer()}")
    File.mkdir_p!(tmp_dir)
    File.write!(Path.join(tmp_dir, "MyExtra-Regular.otf"), "")

    Application.put_env(:blendend_playground, :font_paths, [tmp_dir])
    Fonts.refresh()

    assert {:ok, font} = Fonts.get("myextra")
    assert [%{path: path}] = font.variations
    assert String.contains?(path, "MyExtra-Regular.otf")
  end
end

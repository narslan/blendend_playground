defmodule BlendendPlayground.Palette.Macros do
  @moduledoc """
  Macro wrappers around `BlendendPlayground.Palette` helpers.
  """

  alias BlendendPlayground.Palette

  defmacro __using__(_opts) do
    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__)
    end
  end

  defmacro from_hex_list(hex_list) do
    quote bind_quoted: [hex_list: hex_list] do
      Palette.from_hex_list(hex_list)
    end
  end
end

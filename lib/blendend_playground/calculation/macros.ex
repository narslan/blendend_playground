defmodule BlendendPlayground.Calculation.Macros do
  @moduledoc """
  Macro wrappers around `BlendendPlayground.Calculation` helpers for inline math.
  """

  alias BlendendPlayground.Calculation

  defmacro __using__(_opts) do
    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__)
    end
  end

  defmacro map(value, in_min, in_max, out_min, out_max) do
    quote do
      unquote(Calculation).map(
        unquote(value),
        unquote(in_min),
        unquote(in_max),
        unquote(out_min),
        unquote(out_max)
      )
    end
  end

  defmacro norm(value, start, stop) do
    quote do
      unquote(Calculation).norm(
        unquote(value),
        unquote(start),
        unquote(stop)
      )
    end
  end

  defmacro lerp(start, stop, amt) do
    quote do
      unquote(Calculation).lerp(
        unquote(start),
        unquote(stop),
        unquote(amt)
      )
    end
  end
end

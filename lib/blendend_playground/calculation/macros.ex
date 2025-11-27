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
    quote bind_quoted: [
            value: value,
            in_min: in_min,
            in_max: in_max,
            out_min: out_min,
            out_max: out_max
          ] do
      Calculation.map(value, in_min, in_max, out_min, out_max)
    end
  end

  defmacro norm(value, start, stop) do
    quote bind_quoted: [value: value, start: start, stop: stop] do
      Calculation.norm(value, start, stop)
    end
  end

  defmacro lerp(start, stop, amt) do
    quote bind_quoted: [start: start, stop: stop, amt: amt] do
      Calculation.lerp(start, stop, amt)
    end
  end

  defmacro sq(value) do
    quote bind_quoted: [value: value] do
      Calculation.sq(value)
    end
  end

  defmacro sqrt(value) do
    quote bind_quoted: [value: value] do
      Calculation.sqrt(value)
    end
  end
end

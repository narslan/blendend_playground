defmodule BlendendPlayground.Calculation do
  @moduledoc """
  Utility helpers inspired by p5.js math functions, exposed as both functions and macros
  so they can be used inline within drawing pipelines.
  """

  @doc """
  Maps a value from one range to another.

  Raises `ArgumentError` when the input range is zero-length.
  """
  @spec map(number(), number(), number(), number(), number()) :: float()
  def map(value, in_min, in_max, out_min, out_max) do
    in_span = in_max - in_min
    out_span = out_max - out_min

    if in_span == 0 do
      raise ArgumentError, "cannot map with zero input range"
    end

    out_min + (value - in_min) / in_span * out_span
  end

  @doc """
  Normalizes a value within a range to 0..1.
  """
  @spec norm(number(), number(), number()) :: float()
  def norm(value, start, stop) do
    map(value, start, stop, 0.0, 1.0)
  end

  @doc """
  Linearly interpolates between two numbers.
  """
  @spec lerp(number(), number(), number()) :: float()
  def lerp(start, stop, amt) do
    start + (stop - start) * amt
  end

  @doc """
  Squares a number.
  """
  @spec sq(number()) :: number()
  def sq(value), do: value * value

  @doc """
  Square root helper (delegates to :math.sqrt).
  """
  @spec sqrt(number()) :: float()
  def sqrt(value), do: :math.sqrt(value)

  @doc """
  Generates a random angle in radians between -π and +π.
  """
  @spec rand_radian() :: float()
  def rand_radian do
    (:rand.uniform() * 2 - 1) * :math.pi()
  end

  @doc """
  Picks a random float between `min` and `max` (inclusive of `min`, exclusive of `max`).

  Swaps the arguments if they are provided in reverse order.
  """
  @spec rand_between(number(), number()) :: float()
  def rand_between(min, max) do
    {low, high} = if min <= max, do: {min, max}, else: {max, min}

    case high - low do
      0 -> low * 1.0
      span -> low + :rand.uniform() * span
    end
  end
end

defmodule BlendendPlayground.Demos.LSystem do
  @moduledoc """
  Minimal L-system helpers for deterministic, context-free (DOL) grammars with
  bracketed turtle interpretation.

  `derive/3` rewrites a word `n` times using the provided rules.
  `draw/2` interprets the resulting string with a turtle that understands:
    * \"F\" -> forward + draw
    * \"+\"/\"-\" -> rotate by `angle`
    * \"[\"/\" ]\" -> push/pop position and heading
  """
  import Blendend.Draw, only: [line: 5]
  import Blendend.Style.Color, only: [rgb: 3]

  @type replacement :: String.t() | [String.t()]
  @type rules :: %{String.t() => replacement()}

  @doc """
  Apply deterministic, context-free rules to a word `n` times (parallel rewrite).
  """
  @spec derive(String.t(), rules(), non_neg_integer()) :: String.t()
  def derive(axiom, rules, n) when n >= 0 do
    Enum.reduce(1..n, axiom, fn _, word ->
      word
      |> tokenize()
      |> Enum.map_join(fn sym ->
        case Map.get(rules, sym) do
          nil -> sym
          repl when is_list(repl) -> Enum.random(repl)
          repl -> repl
        end
      end)
    end)
  end

  @doc """
  Interpret a word with a simple turtle. Options:
    * :len (float)    - segment length (default 20.0)
    * :angle (float)  - turn angle in radians (default pi/6)
    * :origin {x,y}   - starting point (default {0, 0})
    * :heading float  - starting heading radians (default -pi/2, i.e. up)
    * :stroke any     - stroke color (default rgb(30,30,30))
    * :stroke_width f - stroke width (default 1.5)
    * :forward [sym]  - symbols that mean "draw forward" (default ["F"])
  """
  @spec draw(String.t(), keyword()) :: :ok
  def draw(word, opts \\ []) do
    len = opts[:len] || 20.0
    angle = opts[:angle] || :math.pi() / 6
    {x0, y0} = opts[:origin] || {0.0, 0.0}
    heading0 = opts[:heading] || -:math.pi() / 2
    stroke = opts[:stroke] || rgb(30, 30, 30)
    stroke_width = opts[:stroke_width] || 1.5
    forward_syms = MapSet.new(opts[:forward] || ["F"])

    word
    |> tokenize()
    |> Enum.reduce({x0, y0, heading0, [], len}, fn
      sym, {cx, cy, h, st, seg_len} ->
        cond do
          MapSet.member?(forward_syms, sym) ->
            nx = cx + seg_len * :math.cos(h)
            ny = cy + seg_len * :math.sin(h)
            line cx, cy, nx, ny, stroke: stroke, stroke_width: stroke_width
            {nx, ny, h, st, seg_len}

          sym == "+" ->
            {cx, cy, h + angle, st, seg_len}

          sym == "-" ->
            {cx, cy, h - angle, st, seg_len}

          sym == "[" ->
            {cx, cy, h, [{cx, cy, h, seg_len} | st], seg_len}

          sym == "]" and match?([{_, _, _, _} | _], st) ->
            [{px, py, ph, pl} | rest] = st
            {px, py, ph, rest, pl}

          true ->
            {cx, cy, h, st, seg_len}
        end
    end)

    :ok
  end

  # Tokenize with support for letter+optional digit symbols (e.g., F0, F1, X) plus + - [ ].
  defp tokenize(word) do
    Regex.scan(~r/[A-Za-z][0-9]?|\+|\-|\[|\]/u, word, capture: :first)
    |> List.flatten()
  end
end

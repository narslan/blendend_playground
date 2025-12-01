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
  import Blendend.Draw, only: [line: 5, fill_path: 2, stroke_path: 2]
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
            line(cx, cy, nx, ny, stroke: stroke, stroke_width: stroke_width)
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

  @doc """
  Interpret a word with 3D turtle semantics (+ - & ^ \\ / | [ ] { } F f ! ').
  Projects to 2D with a simple isometric transform (x' = x + z*k, y' = y - z*k).
  Options:
    * :len            - segment length (default 12.0)
    * :angle          - rotation angle in radians (default pi/10)
    * :origin         - {x,y,z} start (default {0,0,0})
    * :heading        - initial orientation matrix (default identity)
    * :dia            - starting diameter (default 1.6)
    * :dia_step       - decrement for '!' (default 0.2)
    * :colors         - list of colors for strokes/fills (default [rgb(50,60,50)])
    * :proj_k         - isometric skew factor for z (default 0.35)
  """
  @spec draw_3d(String.t(), keyword()) :: :ok
  def draw_3d(word, opts \\ []) do
    len = opts[:len] || 12.0
    angle = opts[:angle] || :math.pi() / 10
    {x0, y0, z0} = opts[:origin] || {0.0, 0.0, 0.0}
    r0 = opts[:heading] || ident()
    dia0 = opts[:dia] || 1.6
    dia_step = opts[:dia_step] || 0.2
    colors = opts[:colors] || [rgb(50, 60, 50)]
    proj_k = opts[:proj_k] || 0.35
    leaf_len = opts[:leaf_len] || len * 0.6
    leaf_width = opts[:leaf_width] || len * 0.3
    leaf_color = opts[:leaf_color]
    wedge_color = opts[:wedge_color]

    tokens = tokenize(word)

    Enum.reduce(tokens, {%{x: x0, y: y0, z: z0}, r0, dia0, 0, 1.0, [], nil}, fn sym,
                                                                                {pos, rot, dia,
                                                                                 cidx, len_scale,
                                                                                 stack, wedge} ->
      cond do
        sym == "F" or sym == "f" ->
          seg_len = len * len_scale
          dir = mat_mul_vec(rot, {seg_len, 0.0, 0.0})
          pos2 = %{x: pos.x + elem(dir, 0), y: pos.y + elem(dir, 1), z: pos.z + elem(dir, 2)}

          wedge2 =
            case wedge do
              nil -> nil
              verts -> verts ++ [proj(pos2, proj_k)]
            end

          if sym == "F" do
            {px1, py1} = proj(pos, proj_k)
            {px2, py2} = proj(pos2, proj_k)
            color = Enum.at(colors, rem(cidx, length(colors)))
            line(px1, py1, px2, py2, stroke: color, stroke_width: dia)
          end

          {pos2, rot, dia, cidx, len_scale, stack, wedge2}

        sym == "+" ->
          {pos, mat_mul(rot, ru(angle)), dia, cidx, len_scale, stack, wedge}

        sym == "-" ->
          {pos, mat_mul(rot, ru(-angle)), dia, cidx, len_scale, stack, wedge}

        sym == "&" or sym == "∧" ->
          {pos, mat_mul(rot, rl(angle)), dia, cidx, len_scale, stack, wedge}

        sym == "^" ->
          {pos, mat_mul(rot, rl(-angle)), dia, cidx, len_scale, stack, wedge}

        sym == "\\" ->
          {pos, mat_mul(rot, rh(angle)), dia, cidx, len_scale, stack, wedge}

        sym == "/" ->
          {pos, mat_mul(rot, rh(-angle)), dia, cidx, len_scale, stack, wedge}

        sym == "|" ->
          {pos, mat_mul(rot, ru(:math.pi())), dia, cidx, len_scale, stack, wedge}

        sym == "[" ->
          {pos, rot, dia, cidx, len_scale, [{pos, rot, dia, cidx, len_scale} | stack], wedge}

        sym == "]" and match?([{_, _, _, _, _} | _], stack) ->
          [{p, r, d, ci, ls} | rest] = stack
          {p, r, d, ci, ls, rest, wedge}

        sym == "!" ->
          {pos, rot, max(dia - dia_step, 0.2), cidx, len_scale, stack, wedge}

        sym == "'" ->
          {pos, rot, dia, cidx + 1, len_scale, stack, wedge}

        sym == "<" ->
          {pos, rot, dia, cidx, len_scale * 0.5, stack, wedge}

        sym == ">" ->
          {pos, rot, dia, cidx, len_scale * 2.0, stack, wedge}

        sym == "{" ->
          {pos, rot, dia, cidx, len_scale, stack, [proj(pos, proj_k)]}

        sym == "}" and is_list(wedge) and length(wedge) > 2 ->
          {p, _} =
            Enum.reduce(wedge, {Blendend.Path.new!(), true}, fn {px, py}, {acc, first?} ->
              if first? do
                {Blendend.Path.move_to!(acc, px, py), false}
              else
                {Blendend.Path.line_to!(acc, px, py), false}
              end
            end)

          p = Blendend.Path.close!(p)

          color = wedge_color || Enum.at(colors, rem(cidx, length(colors)))
          fill_path(p, fill: color)
          {pos, rot, dia, cidx, len_scale, stack, nil}

        sym == "leaf" ->
          dir = mat_mul_vec(rot, {1.0, 0.0, 0.0})
          side = mat_mul_vec(rot, {0.0, 1.0, 0.0})

          tip = %{x: pos.x + elem(dir, 0) * leaf_len, y: pos.y + elem(dir, 1) * leaf_len, z: pos.z + elem(dir, 2) * leaf_len}
          ctl = %{x: pos.x + elem(side, 0) * leaf_width, y: pos.y + elem(side, 1) * leaf_width, z: pos.z + elem(side, 2) * leaf_width}

          {p0x, p0y} = proj(pos, proj_k)
          {tpx, tpy} = proj(tip, proj_k)
          {c1x, c1y} = proj(ctl, proj_k)
          {c2x, c2y} = {p0x * 2 - c1x, p0y * 2 - c1y}

          p =
            Blendend.Path.new!()
            |> Blendend.Path.move_to!(p0x, p0y)
            |> Blendend.Path.quad_to!(c1x, c1y, tpx, tpy)
            |> Blendend.Path.quad_to!(c2x, c2y, p0x, p0y)
            |> Blendend.Path.close!()

          fill_path(p, fill: leaf_color || Enum.at(colors, rem(cidx, length(colors))))
          {pos, rot, dia, cidx, len_scale, stack, wedge}

        true ->
          {pos, rot, dia, cidx, len_scale, stack, wedge}
      end
    end)

    :ok
  end

  # Tokenize with support for word symbols (letters with optional digit) plus common turtle tokens.
  defp tokenize(word) do
    Regex.scan(~r/[A-Za-z]+[0-9]?|\+|\-|\[|\]|\/|&|'|\\|\{|\}|\^|\||!|<|>/u, word,
      capture: :first
    )
    |> List.flatten()
  end

  def draw_rhomb(kind, {x, y, h}, len, skew_angle, colors, stroke) do
    # four corners starting at (x,y), heading h, skewed by +/- skew_angle
    {p, _} =
      [
        {x, y},
        {x + len * :math.cos(h), y + len * :math.sin(h)},
        {x + len * :math.cos(h + skew_angle), y + len * :math.sin(h + skew_angle)},
        {x + len * :math.cos(h - (:math.pi() - skew_angle)),
         y + len * :math.sin(h - (:math.pi() - skew_angle))}
      ]
      |> Enum.reduce({Blendend.Path.new!(), true}, fn {px, py}, {acc, first?} ->
        if first? do
          {Blendend.Path.move_to!(acc, px, py), false}
        else
          {Blendend.Path.line_to!(acc, px, py), false}
        end
      end)

    p = Blendend.Path.close!(p)

    fill_path(p, fill: Map.fetch!(colors, kind))
    stroke_path(p, stroke: stroke)
  end

  # Matrix helpers (3x3) and projection
  defp ident, do: {{1.0, 0.0, 0.0}, {0.0, 1.0, 0.0}, {0.0, 0.0, 1.0}}

  defp ru(a) do
    c = :math.cos(a)
    s = :math.sin(a)
    {{c, s, 0.0}, {-s, c, 0.0}, {0.0, 0.0, 1.0}}
  end

  defp rl(a) do
    c = :math.cos(a)
    s = :math.sin(a)
    {{c, 0.0, -s}, {0.0, 1.0, 0.0}, {s, 0.0, c}}
  end

  defp rh(a) do
    c = :math.cos(a)
    s = :math.sin(a)
    {{1.0, 0.0, 0.0}, {0.0, c, -s}, {0.0, s, c}}
  end

  defp mat_mul(
         {{a11, a12, a13}, {a21, a22, a23}, {a31, a32, a33}},
         {{b11, b12, b13}, {b21, b22, b23}, {b31, b32, b33}}
       ) do
    {
      {a11 * b11 + a12 * b21 + a13 * b31, a11 * b12 + a12 * b22 + a13 * b32,
       a11 * b13 + a12 * b23 + a13 * b33},
      {a21 * b11 + a22 * b21 + a23 * b31, a21 * b12 + a22 * b22 + a23 * b32,
       a21 * b13 + a22 * b23 + a23 * b33},
      {a31 * b11 + a32 * b21 + a33 * b31, a31 * b12 + a32 * b22 + a33 * b32,
       a31 * b13 + a32 * b23 + a33 * b33}
    }
  end

  defp mat_mul_vec({{a11, a12, a13}, {a21, a22, a23}, {a31, a32, a33}}, {x, y, z}) do
    {
      a11 * x + a12 * y + a13 * z,
      a21 * x + a22 * y + a23 * z,
      a31 * x + a32 * y + a33 * z
    }
  end

  defp proj(%{x: x, y: y, z: z}, k), do: {x + z * k, y - z * k}
end

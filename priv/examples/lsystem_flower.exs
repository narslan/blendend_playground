# Plant with flowers and leaves (adapted to 2D from a bracketed L-system).
alias BlendendPlayground.Demos.LSystem

draw 900, 1100 do
  clear(fill: rgb(250, 250, 250))

 
  
  axiom = "plant"

  rules = %{
    "plant" =>
      "internode+[plant+flower]--[--leaf]internode[++leaf]-[plantflower]++plantflower",
    "internode" => "Fseg[/ /leaf][/ /leaf]Fseg",
    "seg" => "segFseg",
    "leaf" => "[ ' {+f-ff-f+|+f-ff-f} ]",
    "flower" => "[pedicel / wedge / wedge / wedge / wedge / wedge]",
    "pedicel" => "FF",
    "wedge" => "[ F][ { -f+f|-f+f } ]"
  }

  iterations = 4
  word = LSystem.derive(axiom, rules, iterations)

  angle = :math.pi() * 18.0 / 180.0
  len = 6.0

  # Simple renderer for this grammar: draws forward tokens, ignores 3D rolls,
  # and renders leaves/flowers as small 2D shapes.
  tokens = Regex.scan(~r/[A-Za-z]+[0-9]?|\+|\-|\[|\]|\/|&|'/u, word, capture: :first) |> List.flatten()

  draw_leaf = fn x, y, heading ->
    sz = 6.0
    hx = x + sz * :math.cos(heading)
    hy = y + sz * :math.sin(heading)
    px1 = hx + sz * 0.6 * :math.cos(heading + 0.4)
    py1 = hy + sz * 0.6 * :math.sin(heading + 0.4)
    px2 = hx + sz * 0.6 * :math.cos(heading - 0.4)
    py2 = hy + sz * 0.6 * :math.sin(heading - 0.4)

    p =
      Blendend.Path.new!()
      |> Blendend.Path.move_to!(x, y)
      |> Blendend.Path.line_to!(hx, hy)
      |> Blendend.Path.line_to!(px1, py1)
      |> Blendend.Path.line_to!(hx, hy)
      |> Blendend.Path.line_to!(px2, py2)
      |> Blendend.Path.close!()

    fill_path(p, fill: rgb(70, 140, 70))
  end

  draw_flower = fn x, y ->
    petals = 6
    r0 = 3.0
    r1 = 9.0
    p =
      Enum.reduce(0..(petals - 1), Blendend.Path.new!(), fn i, acc ->
        a0 = i * 2 * :math.pi() / petals
        a1 = a0 + :math.pi() / petals
        acc
        |> Blendend.Path.move_to!(x + r0 * :math.cos(a0), y + r0 * :math.sin(a0))
        |> Blendend.Path.line_to!(x + r1 * :math.cos(a1), y + r1 * :math.sin(a1))
        |> Blendend.Path.line_to!(x + r0 * :math.cos(a0 + 2 * :math.pi() / petals),
          y + r0 * :math.sin(a0 + 2 * :math.pi() / petals))
      end)

    fill_path(p, fill: rgb(220, 120, 160))
  end

  Enum.reduce(tokens, {450.0, 1050.0, -:math.pi() / 2, []}, fn
    sym, {x, y, h, stack} ->
      cond do
        sym in ["F", "seg", "internode", "pedicel"] ->
          nx = x + len * :math.cos(h)
          ny = y + len * :math.sin(h)
          line(x, y, nx, ny, stroke: rgb(60, 60, 60), stroke_width: 1.2)
          {nx, ny, h, stack}

        sym == "leaf" ->
          draw_leaf.(x, y, h)
          {x, y, h, stack}

        sym == "flower" ->
          draw_flower.(x, y)
          {x, y, h, stack}

        sym == "+" ->
          {x, y, h + angle, stack}

        sym == "-" ->
          {x, y, h - angle, stack}

        sym == "[" ->
          {x, y, h, [{x, y, h} | stack]}

        sym == "]" and match?([{_, _, _} | _], stack) ->
          [{px, py, ph} | rest] = stack
          {px, py, ph, rest}

        true ->
          {x, y, h, stack} # ignore / & ' and other controls
      end
  end)
end

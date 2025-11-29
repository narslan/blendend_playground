# https://openprocessing.org/sketch/2497472
use BlendendPlayground.Calculation.Macros
use Blendend.Draw
alias BlendendPlayground.Palette
alias Blendend.Style.Gradient
alias Blendend.Path

defmodule BlendendPlayground.Demos.NightHouse do
  # drawHouse(x, y + hStep + ny, xStep, h, palette);
  def draw_house(x, y, w, h, palette) do
    palette = Enum.shuffle(palette)

    w2 = rand_between(w / 8, w / 2)
    bool = if :rand.uniform() > 0.5, do: true, else: false

    translate x, y do
      if bool do
        translate(w, 0)
        scale(-1, 1)
      end

      scl = rand_between(0.75, 1.25)
      scale(scl, 1)
      # set_stroke_width(1 / scl)
      # draw chimneys
      if :rand.uniform() > 0.5 do
        {ch, cs, cv} = List.last(palette)
        c = hsv(ch, cs, max(cv - 0.2, 0))
        y0_temp = -rand_between(w / 3, w / 8)
        x1_temp = -rand_between(w / 15, w / 10)
        rect(w / 2, y0_temp, x1_temp, h, fill: c)
      end

      # fascia
      set_fill_style(hsv(0, 0, 1))

      p =
        Path.new!()
        |> Path.move_to!(0, w2)
        |> Path.line_to!(w / 4, 0)
        |> Path.line_to!(w * 3 / 4, 0)
        |> Path.line_to!(w, w2)
        |> Path.line_to!(w, h)
        |> Path.line_to!(0, h)
        |> Path.close!()

      fill_path(p)

      shadow_path(p, 0.0, 0, w / 3, fill: rgb(0, 0, 0, 33), resolution: 0.2)

      # roof
      {ch, cs, cv} = Enum.at(palette, 0)

      grad2 =
        Gradient.linear_from_stops(
          {0, 0, 0, w2},
          [
            {0.0, hsv(ch, cs, cv)},
            {1.0, hsv(ch, cs, max(cv - 0.2, 0))}
          ]
        )

      p2 =
        Path.new!()
        |> Path.move_to!(w / 4, 0)
        |> Path.line_to!(w * 3 / 4, 0)
        |> Path.line_to!(w, w2)
        |> Path.line_to!(w / 2, w2)
        |> Path.close!()

      fill_path(p2, fill: grad2)

      # wind
      {ch, cs, cv} = Enum.at(palette, 1)

      grad3 =
        Gradient.linear_from_stops(
          {0, w2, 0, h},
          [
            {0.0, hsv(ch, cs, cv)},
            {0.1, hsv(ch, cs, max(cv - 0.2, 0))}
          ]
        )

      p3 =
        Path.new!()
        |> Path.move_to!(w / 2, w2)
        |> Path.line_to!(w, w2)
        |> Path.line_to!(w, h)
        |> Path.line_to!(w / 2, h)
        |> Path.close!()

      fill_path(p3, fill: grad3)

      # fascia 2

      c3 = Enum.at(palette, 2)
      c4 = Enum.at(palette, 3)

      grad4 =
        Gradient.linear_from_stops(
          {0, 0, 0, h},
          [
            {0.0, hsv(c3)},
            {1 / 15, hsv(c4)}
          ]
        )

      p4 =
        Path.new!()
        |> Path.move_to!(0, w2)
        |> Path.line_to!(w / 4, 0)
        |> Path.line_to!(w / 2, w2)
        |> Path.line_to!(w / 2, h)
        |> Path.line_to!(0, h)
        |> Path.close!()

      fill_path(p4, fill: grad4)

      fc = Enum.at(palette, length(palette) - 2)
      x_translate_amount = if :rand.uniform() > 0.5, do: 0, else: w / 2
      translate(x_translate_amount, w2)
      h2 = w / 2 * rand_between(0.5, 1)
      translate(w / 4, h2)
      rect_center(0, 0, w / 4, h2, fill: fc)
    end
  end

  def walk_rows(y0, height, fun) do
    if y0 < height do
      # compute current step
      y_step = map(y0, height / 4, height, height / 50, height / 20)
      fun.(y0)
      walk_rows(y0 + y_step, height, fun)
    end
  end

  def walk_cols(x0, width, step_base_fun, house_fun) do
    if x0 < width do
      x_step_base = step_base_fun.()
      x_step = rand_between(x_step_base / 2, x_step_base * 2)
      house_fun.(x0, x_step)
      walk_cols(x0 + x_step, width, step_base_fun, house_fun)
    end
  end
end

width = 800
height = 800
alias BlendendPlayground.Demos.NightHouse

draw width, height do
  set_stroke_join(:round)

  gradient =
    Gradient.linear_from_stops(
      {0, 0, 0, height},
      [{0.0, hsv(220, 0.8, 0.0)}, {0.4, hsv(220, 0.8, 0.7)}]
    )

  set_fill_style(gradient)

  clear(fill: gradient)

  for _ <- 0..div(width * height, 100) do
    x = Enum.random(1..width)

    y =
      :rand.uniform() * :rand.uniform() * :rand.uniform() * :rand.uniform() * height * 1.5 -
        height * 0.15

    circle(x, y, 0.5, stroke: rgb(255, 255, 255, Enum.random(100..255)))
  end

  w = height / 10 / 1.5
  h = height * 2
  noise_scale = 0.1
  palette = Palette.scheme_hsv(:random)

  comp_op(:multiply)

  NightHouse.walk_rows(height / 4, height, fn y ->
    x_step_base = map(y, height / 4, height, w / 2, w * 3)

    NightHouse.walk_cols(0.0, width, fn -> x_step_base end, fn x, x_step ->
      n_raw = Perlin.noise(x * noise_scale, y * noise_scale, 0.0)
      ny = (n_raw + 1.0) / 2.0 * height / 2

      h_step =
        map(y, height / 4, height, height / 100, height / 10) *
          if :rand.uniform() > 0.5, do: -1, else: 1

      # comp_op :plus
      NightHouse.draw_house(x, y + h_step + ny, x_step, h, palette)
    end)

    gradient2 =
      Gradient.linear_from_stops(
        {0, y, 0, height},
        [{1.0, hsv(0, 0, 0, 1)}, {0.0, hsv(0, 0, 0, 0)}]
      )

    set_fill_style(gradient2)
    comp_op(:src_over)

    # blend/gradient work per row here
  end)
end

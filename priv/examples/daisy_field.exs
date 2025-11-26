#Port of https://openprocessing.org/sketch/2522094.
alias Blendend.Path
alias Blendend.Style.Color
use Blendend.Draw

defmodule BlendendPlayground.Demos.DaisyField do
  @tau :math.pi() * 2
  @petal_colors ["#3f88c5", "#c1292e", "#ffffff", "#ed91bd", "#17bebb", "#f1d302", "#2e933c"]
 # @petal_colors ["#5EC8F2",  "#459DBF",   "#F26D6D",  "#D9D16A", "#C1D9CE", "#2e933c", "#F2F2F2", "#F2E6D8"]
  @center_colors [ "#f2dd52", "#f0c330","#F2B705",  "#F2A950", "#F2AE2E"]

  def draw_flower(x, y, w) do
    num = rand_int(11, 15)
    aa = rand_range(0.0, 10.0)

    petals =
      Enum.map(0..(num - 1), fn i ->
        a = map_range(i, 0, num, 0.0, @tau) + aa
        %{x: x, y: y, w: w * 0.5, a: a}
      end)
      |> Enum.shuffle()

    #petal_colors = scheme(:hokusai_blue)
    #center_colors = scheme(:mono)
    fill_color = rand_pick(@petal_colors) |> hex_color()

    Enum.each(petals, fn %{x: px, y: py, w: pw, a: pa} ->
      draw_petal(px, py, pw, pa, fill_color)
    end)

    set_stroke_style(rgb(0, 0, 0))
    set_stroke_width(w * 0.013)
    center_color = rand_pick(@center_colors) |> hex_color()
    draw_irregular_circle(x, y, w * rand_range(0.25, 0.3), center_color)
  end

  defp draw_petal(x, y, w, a, fill_color) do
    ap1 = %{x: 0.0, y: -w * 0.025, a1: 0.0, a2: 0.0, r1: 0.0, r2: 0.0}

    ap2 = %{
      x: w * rand_range(0.5, 0.7),
      y: -w * rand_range(0.125, 0.175),
      a1: :math.pi(),
      a2: 0.0,
      r1: w * rand_range(0.19, 0.21),
      r2: w * rand_range(0.19, 0.21)
    }

    ap3 = %{
      x: w,
      y: 0.0,
      a1: -(:math.pi() / 2) + :math.pi() * rand_range(-0.02, 0.02),
      a2: :math.pi() / 2 + :math.pi() * rand_range(-0.02, 0.02),
      r1: w * rand_range(0.08, 0.12),
      r2: w * rand_range(0.08, 0.12)
    }

    ap4 = %{
      x: w * rand_range(0.5, 0.7),
      y: w * rand_range(0.125, 0.175),
      a1: 0.0,
      a2: :math.pi(),
      r1: w * rand_range(0.19, 0.21),
      r2: w * rand_range(0.19, 0.21)
    }

    ap5 = %{x: 0.0, y: w * 0.025, a1: 0.0, a2: 0.0, r1: 0.0, r2: 0.0}

    path =
      Path.new!()
      |> Path.move_to!(ap1.x, ap1.y)
      |> add_segment(ap1, ap2)
      |> add_segment(ap2, ap3)
      |> add_segment(ap3, ap4)
      |> add_segment(ap4, ap5)
      |> Path.close!()

    translate x, y do
      rotate a do
        fill_path(path, fill: fill_color)
        stroke_path(path, stroke_width: w * 0.015)

        veiny = w * 0.015
        line(0.0, 0.0, w * rand_range(0.4, 0.7), w * rand_range(0.02, 0.04), stroke_width: veiny)
        line(0.0, 0.0, w * rand_range(0.4, 0.7), -w * rand_range(0.02, 0.04), stroke_width: veiny)
      end
    end
  end

  defp add_segment(path, a, b) do
    {h1x, h1y} = polar_to_cart(a.x, a.y, a.r2, a.a2)
    {h2x, h2y} = polar_to_cart(b.x, b.y, b.r1, b.a1)
    Path.cubic_to!(path, h1x, h1y, h2x, h2y, b.x, b.y)
  end

  defp draw_irregular_circle(x, y, d, fill_color) do
    angles = Enum.map(0..90, &(&1 * (@tau / 90)))
    {fx, fy} = noisy_point(x, y, d, hd(angles))

    path =
      Path.new!()
      |> Path.move_to!(fx, fy)

    angles
    |> tl()
    |> Enum.each(fn ang ->
      {px, py} = noisy_point(x, y, d, ang)
      Path.line_to!(path, px, py)
    end)

    Path.close!(path)

    fill_path path, fill: fill_color
    stroke_path path, stroke_width: d * 0.013

    Enum.each(1..round(d * 5), fn _ ->
      a = :rand.uniform() * @tau
      r = d / 2.0 * (1.0 - rand_nested())
      px = x + r * cos(a)
      py = y + r * sin(a)
      circle(px, py, 0.6, fill: rgb(0, 0, 0))
    end)
  end

  defp polar_to_cart(cx, cy, r, angle) do
    {cx + cos(angle) * r, cy + sin(angle) * r}
  end

  defp noisy_point(cx, cy, d, angle) do
    offset = rand_range(-2.0, 1.0) * d * 0.01
    r = d / 2.0 + offset
    {cx + r * cos(angle), cy + r * sin(angle)}
  end

  defp hex_color("#" <> <<r1::binary-size(2), g1::binary-size(2), b1::binary-size(2)>>) do
    rgb(String.to_integer(r1, 16), String.to_integer(g1, 16), String.to_integer(b1, 16))
  end

  def rand_range(min, max), do: min + :rand.uniform() * (max - min)
  defp rand_int(min, max), do: :rand.uniform(max - min + 1) + min - 1
  defp rand_pick(list), do: Enum.random(list)

  defp rand_nested do
    # product of uniforms ≈ random(random(random(random()))) in p5
    :rand.uniform() * :rand.uniform() * :rand.uniform() * :rand.uniform()
  end

  defp map_range(v, in_min, in_max, out_min, out_max) do
    t = (v - in_min) / (in_max - in_min)
    out_min + t * (out_max - out_min)
  end
end

width = 800
height = 800
alias BlendendPlayground.Demos.DaisyField

draw width, height do
  clear(fill: rgb(235, 235, 235))

  Enum.each(1..1000, fn _ ->
    w = DaisyField.rand_range(0.08, 0.12) * width
    x = :rand.uniform() * width
    y = :rand.uniform() * height
    set_stroke_width(w * 0.015)
    DaisyField.draw_flower(x, y, w)
  end)
end

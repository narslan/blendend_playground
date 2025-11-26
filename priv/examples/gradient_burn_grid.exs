# Port of a p5.js burn/gradient tile demo to Blendend.
# Draws randomly sized cells filled with linear/radial gradients, layered with color burn.
use Blendend.Draw

defmodule BlendendPlayground.Demos.GradientBurnGrid do
  @palettes [
    ["#20191b", "#67875c", "#f3cb4d", "#f2f5e3"],
    ["#001219", "#005f73", "#0a9396", "#94d2bd", "#e9d8a6", "#ee9b00", "#ca6702", "#bb3e03", "#ae2012", "#9b2226"],
    ["#bab9a4", "#311f27", "#ff3931", "#007861"],
    ["#f94144", "#f3722c", "#f8961e", "#f9c74f", "#90be6d", "#43aa8b", "#577590"],
    ["#f4c172", "#7b8a56", "#363d4a", "#ff9369"],
    ["#af592c", "#f0e0c6", "#2a1f1d", "#7a999c", "#df4a33", "#475b62", "#fbaf3c"],
    ["#20342a", "#f74713", "#e9b4a6", "#686d2c"],
    ["#687d99", "#aa3a33", "#6c843e", "#705f84", "#dc383a", "#9c4257", "#fc9a1a"],
    ["#ef476f", "#ffd166", "#06d6a0", "#118ab2", "#073b4c"]
  ]

  
  def render_layer(colors, params) do
    limit = params.diag + params.offset
    step_y(-params.offset, limit, colors, params)
  end

  defp step_y(y, limit, colors, params) when y < limit do
    y_step = set_step(abs(y), limit, params.size)
    step_x(-params.offset, limit, y_step, y, colors, params)
    step_y(y + y_step, limit, colors, params)
  end

  defp step_y(_y, _limit, _colors, _params), do: :ok

  defp step_x(x, limit, y_step, y, colors, params) when x < limit do
    x_step = set_step(abs(x), limit, params.size)

    translate x + x_step / 2, y + y_step / 2 do
      rotate_num = :rand.uniform(4) - 1
      rotate(rotate_num * :math.pi() / 2)

      scale(
        if(:rand.uniform() > 0.5, do: -1, else: 1),
        if(:rand.uniform() > 0.5, do: -1, else: 1)
      )

      {wn, hn} =
        if rem(rotate_num, 2) == 0 do
          {x_step, y_step}
        else
          {y_step, x_step}
        end

      grad = gradient_for_cell(wn, hn, colors)
      shape = choose_shape(params.shape_mode)
      draw_shape(shape, wn, hn, grad)
    end

    step_x(x + x_step, limit, y_step, y, colors, params)
  end

  defp step_x(_x, _limit, _y_step, _y, _colors, _params), do: :ok

  defp draw_shape(shape, wn, hn, grad) do
    d = max(wn, hn)
    opts =
      if :rand.uniform() > 0.25 do
        [gradient: grad]
      else
        [stroke: grad, stroke_width: max(d * 0.05, 1.0)]
      end

    case shape do
      0 -> round_rect(-wn / 2, -hn / 2, wn, hn, d / 2, d / 2, opts)
      1 -> rect(-wn / 2, -hn / 2, wn, hn, opts)
      2 ->
        radius = max(d / :rand.uniform(2), d * 0.4)
        circle(0, 0, radius, opts)

      3 -> pie(0.0, 0.0, d, d, 0.0, :math.pi() / 2, opts)
      4 -> triangle(-wn / 2, -hn / 2, -wn / 2, hn / 2, wn / 2, -hn / 2, opts)
      5 -> polygon(random_polygon(d, Enum.random([3, 4, 6])), opts)
    end
  end

  defp gradient_for_cell(wn, hn, colors) do
    sw = :math.sqrt(wn * wn + hn * hn)
    angle = Enum.random(0..7) * (:math.pi() / 4)
    [c1, c2 | _] = Enum.shuffle(colors)
    stop_clear = rgb(255, 255, 255, 0)

    t = clamp(:rand.uniform(), 0.05, 0.95)
    stops =
      [
        {0.0, rgb_tuple(c1, 220)},
        {t, stop_clear},
        {1.0, rgb_tuple(c2, 220)}
      ]
      |> Enum.sort_by(fn {pos, _} -> pos end)

    if :rand.uniform() > 0.5 do
      Blendend.Style.Gradient.linear_from_stops(
        {:math.cos(angle) * sw / 2, :math.sin(angle) * sw / 2,
         :math.cos(angle + :math.pi()) * sw / 2, :math.sin(angle + :math.pi()) * sw / 2},
        stops
      )
    else
      Blendend.Style.Gradient.radial_from_stops(
        {0.0, 0.0, 0.0, 0.0, 0.0, max(wn, hn)},
        stops
      )
    end
  end

  defp random_polygon(d, sides) do
    for i <- 0..(sides - 1) do
      ang = i * 2 * :math.pi() / sides
      { :math.cos(ang) * d / 2, :math.sin(ang) * d / 2 }
    end
  end

  defp choose_shape(mode) when mode in 0..4, do: mode
  defp choose_shape(_mode), do: Enum.random(0..5)

  def pick_palette do
    @palettes
    |> Enum.random()
    |> Enum.map(&hex_to_tuple/1)
    |> Enum.shuffle()
  end

  defp hex_to_tuple("#" <> hex), do: hex_to_tuple(hex)
  defp hex_to_tuple(<<r::binary-size(2), g::binary-size(2), b::binary-size(2)>>) do
    {String.to_integer(r, 16), String.to_integer(g, 16), String.to_integer(b, 16)}
  end

  def rgb_tuple({r, g, b}, alpha), do: rgb(r, g, b, alpha)

  defp set_step(v, max, size) do
    scl = map_range(size * 1.0, 1.0, 5.0, 5.0, 1.0)
    step = nested_rand() * max / scl
    step = if v + step > max, do: max - v, else: step
    max(step, max * 0.01)
  end

  defp nested_rand do
    :rand.uniform() * :rand.uniform() * :rand.uniform()
  end

  def map_range(v, in_min, in_max, out_min, out_max) do
    t = (v - in_min) / (in_max - in_min)
    out_min + t * (out_max - out_min)
  end

  def clamp(v, lo, hi), do: v |> max(lo) |> min(hi)

  def alpha_to_255(a), do: round(clamp(a, 0.0, 100.0) * 2.55)
end

w = 900
h = 900
alias BlendendPlayground.Demos.GradientBurnGrid, as: Demo

seed = :rand.uniform(1000)

draw w, h do
  
  :rand.seed(:exsss, {seed, seed * 2 + 1, seed * 3 + 7})

   params=  %{
      seed: seed,
      palette: Demo.pick_palette(),
      angle: Enum.random(0..7) * (:math.pi() / 4),
      size: Enum.random(1..5),
      shape_mode: Enum.random(0..5),
      layers: Enum.random(4..7),
      background_alpha: Enum.random(0..100),
      diag: :math.sqrt(w * w + h * h),
      offset: w / 5,
      w: w,
      h: h
    }
  
  
  [bg | colors] = params.palette
    overlay_alpha =
      params.layers
      |> Demo.map_range(1.0, 8.0, params.background_alpha * 1.0, 5.0)
      |> Demo.clamp(0.0, 100.0)
      |> Demo.alpha_to_255()

    clear(fill: rgb(245, 245, 245))
    rect 0, 0, params.w, params.h, fill: Demo.rgb_tuple(bg, overlay_alpha)

    comp_op(:color_burn)

    translate params.w / 2, params.h / 2 do
      rotate params.angle do
        translate(-params.diag / 2, -params.diag / 2) do
          Enum.each(1..params.layers, fn _ ->
            Demo.render_layer(colors, params)
          end)
        end
      end
    end
end

# https://openprocessing.org/crayon/16
alias BlendendPlayground.Palette
use BlendendPlayground.Calculation.Macros

defmodule Steps do
  # set_step as before; capture `size` when you call build_layers/…
  def set_step(v, max, size) do
    scl = (size - 1.0) / (5.0 - 1.0) * (1.0 - 5.0) + 5.0
    # Approximate random(random(random()))
    val = :rand.uniform() * :rand.uniform() * :rand.uniform() * max / scl
    if v + val > max, do: max - v, else: val
  end

  # Walk one axis, yielding {pos, step} until limit
  defp walk_axis(start, limit, size) do
    Stream.unfold(start, fn pos ->
      if pos < limit do
        step = set_step(abs(pos), limit, size)
        {{pos, step}, pos + step}
      else
        nil
      end
    end)
  end

  def layer_cells(w, offset, size) do
    limit = w + offset

    for {y, y_step} <- walk_axis(-offset, limit, size),
        {x, x_step} <- walk_axis(-offset, limit, size) do
      {x, y, x_step, y_step}
    end
  end

  defp draw_cell(x, y, x_step, y_step, palette, shapes) do
    translate x + x_step / 2, y + y_step / 2 do
      # 0,1,2,3
      rotate_num = Enum.random(0..3)
      angle_rad = rotate_num * (:math.pi() / 2)

      rotate angle_rad do
        sx = Enum.random([-1, 1])
        sy = Enum.random([-1, 1])

        scale sx, sy do
          wn = if rem(rotate_num, 2) == 0, do: x_step, else: y_step
          hn = if rem(rotate_num, 2) == 0, do: y_step, else: x_step
          sw = sqrt(sq(wn) + sq(hn))

          angle = Enum.random(0..7) * (:math.pi() / 4)

          grad =
            if :rand.uniform() > 0.5 do
              Blendend.Style.Gradient.linear!(
                cos(angle) * sw / 2,
                sin(angle) * sw / 2,
                cos(:math.pi() + angle) * sw / 2,
                sin(:math.pi() + angle) * sw / 2
              )
            else
              Blendend.Style.Gradient.radial!(
                cos(angle) * sw / 4,
                sin(angle) * sw / 4,
                0,
                0,
                0,
                max(x_step, y_step)
              )
            end

          colors = Enum.shuffle(palette)
          c1 = Enum.at(colors, 0)
          c2 = Enum.at(colors, 1)
          Blendend.Style.Gradient.add_stop!(grad, 0, c1)
          Blendend.Style.Gradient.add_stop!(grad, 1, c2)
          Blendend.Style.Gradient.add_stop!(grad, :rand.uniform(), rgb(0, 0, 0, 0))

          if :rand.uniform() > 0.5 do
            set_style_alpha(:stroke, 0.4)
            set_stroke_style(grad)
            disable_style(:fill)
          else
            set_style_alpha(:fill, 0.4)
            set_fill_style(grad)
            disable_style(:stroke)
          end

          case shapes do
            0 ->
              round_rect(0, 0, wn, hn, max(wn, hn), max(wn, hn))

            1 ->
              rect(0, 0, wn, hn)

            2 ->
              # (1,2]
              denom = 1.0 + :rand.uniform()
              circle(0, 0, max(wn, hn) / denom)

            3 ->
              arc(-wn / 2, -hn / 2, max(wn, hn), max(wn, hn), 0, 90)

            4 ->
              triangle(-wn / 2, -hn / 2, -wn / 2, hn / 2, wn / 2, -hn / 2)

            5 ->
              case Enum.random(0..4) do
                0 ->
                  round_rect(0, 0, wn, hn, max(wn, hn), max(wn, hn))

                1 ->
                  rect(0, 0, wn, hn)

                2 ->
                  denom = 1.0 + :rand.uniform()
                  circle(0, 0, max(wn, hn) / denom)

                3 ->
                  arc(-wn / 2, -hn / 2, max(wn, hn), max(wn, hn), 0, 90)

                4 ->
                  triangle(-wn / 2, -hn / 2, -wn / 2, hn / 2, wn / 2, -hn / 2)

                #5 ->
                #  polygon({0, 0, max(wn, hn), Enum.random([3, 4, 6])})
              end
          end
        end
      end

      # rect x, y, x_step, y_step, fill: Enum.at(palette, 0), comp_op: :src_over 
    end
  end

  def draw_layer(w, offset, size, palette, shapes) do
    clear(fill: rgb(0,0,0,0))

    layer_cells(w, offset, size)
    |> Enum.each(fn {x, y, x_step, y_step} ->
      draw_cell(x, y, x_step, y_step, palette, shapes)
    end)
  end

  def build_layers(layers, w, offset, size, palette, shapes) do
    for _ <- 1..layers do
      draw_layer(w, offset, size, palette, shapes)
    end
  end
end

width = 1200
height = 600

draw width, height do
  palette = Palette.scheme(:vangogh)
  # w = sqrt(sq(width) + sq(height))
  offset = width / 5
  layers = 5
  background_alpha = 9
  alpha = map(layers, 1, 8, background_alpha, 5)
  w = sqrt(sq(width) + sq(height))
  c1 = Enum.at(palette, 0)

  angle = :math.pi() / 90
  clear(fill: hsv(0, 0, 0.95))
  global_alpha(alpha)
  comp_op(:color_burn)
  clear(fill: c1)

  translate width / 2, height / 2 do
    rotate(angle)
    translate(-w / 2, -w / 2)
    comp_op(:src_over)
    Steps.build_layers(5, w, offset, 5, palette, 4)
  end
end

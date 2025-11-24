# Recursive tree sketch that grows branches with fading alpha for depth.
defmodule BlendendPlayground.TreeBranches do
  use Blendend.Draw

  def randf(a, b), do: a + :rand.uniform() * (b - a)

  @max_depth 120
  def max_depth, do: @max_depth
  def branch(x, y, angle, len, thickness, depth) 
       when depth > 0 and len > 1.5 and thickness > 0.3 do
    nx = x + :math.cos(angle) * len
    ny = y + :math.sin(angle) * len

    # fade alpha a bit towards tips
    t = depth / @max_depth
    alpha = trunc(60 + 180 * t)

    line x, y, nx, ny,
      stroke: rgb(230, 230, 230, alpha),
      stroke_width: thickness,
      stroke_cap: :round,
      stroke_line_join: :round

    # main branch bends gently
    next_angle = angle + randf(-0.25, 0.25)

    branch(
      nx,
      ny,
      next_angle,
      len * randf(0.92, 1.02),
      thickness * 0.97,
      depth - 1
    )

    # occasional side branch
    if :rand.uniform() < 0.28 do
      side_angle = angle + randf(-1.0, 1.0)

      branch(
        nx,
        ny,
        side_angle,
        len * randf(0.4, 0.8),
        thickness * 0.75,
        depth - 3
      )
    end
  end

  def branch(_x, _y, _angle, _len, _thickness, _depth), do: :ok
end

alias BlendendPlayground.TreeBranches, as: TB

draw 800, 800 do

   clear fill: rgb(5, 5, 12)

      # put origin near bottom-center
      translate(400, 580)

      # multiple roots starting near the bottom line
      Enum.each(1..8, fn i ->
        start_x = (i - 4) * 40.0
        start_angle = -:math.pi() / 2 + TB.randf(-0.25, 0.25)

        TB.branch(start_x, 0.0, start_angle, 10.0, 3.5, TB.max_depth)
      end)
    end

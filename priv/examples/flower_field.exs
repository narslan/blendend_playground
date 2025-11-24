# Based on https://abu-irrational.github.io/tclBlend2d-Gallery/cards/sample158.html; tweak the code to spawn new fields.
# Randomized quadratic loops create petals at different radii so each render scatters a fresh garden.
alias Blendend.Text.{Face, Font, GlyphBuffer, GlyphRun}
alias Blendend.Path
alias Blendend.Matrix2D
defmodule BlendendPlayground.Demos.FlowerField do
  @pi :math.pi
  defp random(a, b), do: :rand.uniform() * (b - a) + a

  defp midpoint({x0, y0}, {x1, y1}), do: {(x0 + x1) / 2.0, (y0 + y1) / 2.0}

  # addMultiLoop: closed piecewise quadratic bezier through `pts`
  def add_multi_loop(_path, []), do: :ok

  def add_multi_loop(path, [p0 | _] = pts) do
    pz = List.last(pts)
    m0 = midpoint(p0, pz)
    {mx0, my0} = m0

    :ok = Path.move_to(path, mx0, my0)

    
      Enum.drop(pts, 1) |>
      Enum.reduce(p0, fn p1, prev ->
        m = midpoint(prev, p1)
        {cx, cy} = prev
        {ex, ey} = m
        :ok = Path.quad_to(path, cx, cy, ex, ey)
        p1
      end)
    
    {zx, zy} = pz
    {mx, my} = m0
    Path.quad_to(path, zx, zy, mx, my)      
  end

  def generate_flower_points(width, height) do
    x = :rand.uniform() * width
    y = :rand.uniform() * height

    r1 = random(70.0, 150.0)
    r0 = r1 * random(0.1, 0.3)
    nodes = trunc(random(3.0, 20.0))
    curve = random(0.75, 1.0)
    rnd = 0.5 * :rand.uniform()

    slice = @pi / nodes
    sf = slice * curve

    0..(2 * nodes - 1)
    |> Enum.flat_map(fn i ->
      angle = i * slice
      base_r = if rem(i, 2) == 1, do: r0, else: r1
      r = base_r * random(1.0 - rnd, 1.0 + rnd)
      p1 = {
        x + r * :math.cos(angle - sf),
        y + r * :math.sin(angle - sf)
      }

      p2 = {
        x + r * :math.cos(angle + sf),
        y + r * :math.sin(angle + sf)
      }

      [p1, p2]
    end)
  end
  
end


draw 800, 800 do
  
   count = 30
  
   Enum.each(1..count, fn _ ->
        pts = BlendendPlayground.Demos.FlowerField.generate_flower_points(800 * 1.0, 800 * 1.0)

        p = Path.new!()
        
        :ok = BlendendPlayground.Demos.FlowerField.add_multi_loop(p, pts)

        shadow_color = rgb(0, 0, 0, 64)
        flower_color = rgb(:random)

        # puts flower shadow first
        with_transform Matrix2D.translation(8.0, 8.0) do
          fill_path p, fill: shadow_color
        end

        fill_path p, fill: flower_color
      end)
end


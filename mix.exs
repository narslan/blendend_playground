defmodule BlendendPlayground.MixProject do
  use Mix.Project

  def project do
    [
      app: :blendend_playground,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BlendendPlayground.Application, []}
    ]
  end

  defp deps do
    blendend_dep =
      case System.get_env("BLENDEND_LOCAL") do
        "1" -> {:blendend, path: "../blendend"}
        _ -> {:blendend, github: "narslan/blendend"}
      end

    [
      blendend_dep,
      {:plug_cowboy, "~> 2.7"},
      {:perlin, "~> 0.1.0"},
      {:jason, "~> 1.4"}
    ]
  end
end

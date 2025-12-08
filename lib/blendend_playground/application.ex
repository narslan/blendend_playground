defmodule BlendendPlayground.Application do
  use Application

  @impl true
  def start(_type, _args) do
    {:ok, _} = Application.ensure_all_started(:blendend)
    :ok = BlendendPlayground.Palette.init_cache()

    children =
      [
        BlendendPlayground.Fonts,
        {Plug.Cowboy, scheme: :http, plug: BlendendPlayground.Router, options: [port: 4000]}
      ] ++ preview_child()

    opts = [strategy: :one_for_one, name: BlendendPlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp preview_child do
    case System.get_env("BLENDEND_PREVIEW") do
      "1" -> [%{id: BlendendPlayground.HttpPreview, start: {BlendendPlayground.HttpPreview, :start_link, [[]]}}]
      _ -> []
    end
  end
end

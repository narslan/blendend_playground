defmodule BlendendPlayground.Router do
  use Plug.Router

  alias BlendendPlayground.{Examples, Render}

  plug(Plug.Logger)

  plug(Plug.Static,
    at: "/",
    from: :blendend_playground,
    only: ~w(assets)
  )

  plug(Plug.Parsers,
    parsers: [:json, :urlencoded],
    pass: ["*/*"],
    json_decoder: JSON
  )

  plug(:match)
  plug(:dispatch)

  # HTML shell
  get "/" do
    send_resp(conn, 200, index_html())
  end

  get "/swatches" do
    send_resp(conn, 200, swatches_html())
  end

  # -------- examples API --------

  # list all examples
  get "/examples" do
    examples = Examples.all()
    json(conn, %{ok: true, examples: examples})
  end

  # load one example
  get "/examples/:name" do
    case Examples.get(name) do
      nil ->
        json(conn, %{ok: false, error: "not_found"})

      code ->
        json(conn, %{ok: true, name: name, code: code})
    end
  end

  # save new example (fails if exists)
  post "/examples/save" do
    with %{"name" => name, "code" => code} <- conn.body_params do
      case Examples.save(name, code) do
        {:ok, _path} ->
          json(conn, %{ok: true, name: name, examples: Examples.all()})

        {:error, :already_exists} ->
          json(conn, %{ok: false, error: "already_exists"})

        {:error, reason} ->
          json(conn, %{ok: false, error: inspect(reason)})
      end
    else
      _ ->
        json(conn, %{ok: false, error: "invalid_params"})
    end
  end

  # update existing example (fails if missing)
  post "/examples/update" do
    with %{"name" => name, "code" => code} <- conn.body_params do
      case Examples.update(name, code) do
        :ok ->
          json(conn, %{ok: true, name: name, examples: Examples.all()})

        {:error, :not_found} ->
          json(conn, %{ok: false, error: "not_found"})

        {:error, reason} ->
          json(conn, %{ok: false, error: inspect(reason)})
      end
    else
      _ ->
        json(conn, %{ok: false, error: "invalid_params"})
    end
  end

  # -------- render API --------

  post "/render" do
    with %{"code" => code} <- conn.body_params,
         {:ok, base64} <- Render.render(code) do
      json(conn, %{ok: true, image: "data:image/png;base64," <> base64})
    else
      %{} ->
        json(conn, %{ok: false, error: "missing code"})

      {:error, reason} ->
        json(conn, %{ok: false, error: inspect(reason)})
    end
  end

  # -------- swatches API --------

  post "/swatches/render" do
    case conn.body_params do
      %{"colors" => colors} ->
        case BlendendPlayground.Swatches.render(colors) do
          {:ok, base64} ->
            json(conn, %{ok: true, image: "data:image/png;base64," <> base64})

          {:error, reason} ->
            json(conn, %{ok: false, error: inspect(reason)})
        end

      _ ->
        json(conn, %{ok: false, error: "invalid_params"})
    end
  end

  # -------- helpers --------

  defp json(conn, map) do
    body = JSON.encode!(map)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, body)
  end

  defp index_html do
    """
    <!doctype html>
    <html>
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>Blendend Playground</title>
        <!-- Base styling -->
        <link rel="stylesheet" href="/assets/dark.min.css">
        <link rel="stylesheet" href="/assets/style.css">
        <script type="module" src="/assets/app.js"></script>
        <script type="module" src="/assets/playground.js"></script>
      </head>
      <body>
        <main class="layout">
          <nav class="top-nav">
            <a href="/">Playground</a>
            <a href="/swatches">Swatches</a>
          </nav>
          <div id="playground-root"></div>
        </main>
      </body>
    </html>
    """
  end

  defp swatches_html do
    """
    <!doctype html>
    <html>
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>Blendend Swatches</title>
        <link rel="stylesheet" href="/assets/dark.min.css">
        <link rel="stylesheet" href="/assets/style.css">
        <link rel="stylesheet" href="/assets/swatches.css">
        <script type="module" src="/assets/swatches.js"></script>
      </head>
      <body>
        <main class="layout">
          <nav class="top-nav">
            <a href="/">Playground</a>
            <a href="/swatches">Swatches</a>
          </nav>
          <div id="swatches-root"></div>
        </main>
      </body>
    </html>
    """
  end

  # fallback
  match _ do
    send_resp(conn, 404, "not found")
  end
end

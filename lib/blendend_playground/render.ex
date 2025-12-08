defmodule BlendendPlayground.Render do
  @moduledoc """
  Runs Blendend.Draw DSL code and returns {:ok, base64_png} | {:error, reason}.
  """

  def render(code) when is_binary(code) do
    header = """
    use Blendend.Draw
    #{code}
    """

    try do
      {result, _binding} = Code.eval_string(header, [])

      case result do
        {:ok, base64} when is_binary(base64) ->
          {:ok, base64}

        other ->
          {:error, "unexpected result: #{inspect(other)}"}
      end
    rescue
      e -> {:error, Exception.message(e)}
    end
  end
end

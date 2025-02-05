defmodule MakeupEEx do
  @moduledoc """
  Documentation for `MakeupEEx`.
  """

  alias Makeup.Registry

  @doc false
  def dynamic_html_lexer do
    case {Registry.get_lexer_by_name("html"), Registry.get_lexer_by_extension("html")} do
      {nil, nil} ->
        raise """
        The HEEx / EEx+HTML lexer requires an HTML lexer to be registered. You can do this for example by including

            {:makeup_html, "~> 1.0"}

        in your project's dependencies.
        """

      {nil, lexer_tuple} ->
        lexer_tuple

      {lexer_tuple, _} ->
        lexer_tuple
    end
  end
end

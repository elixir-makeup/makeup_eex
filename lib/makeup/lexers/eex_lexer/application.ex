defmodule Makeup.Lexers.EExLexer.Application do
  @moduledoc false
  use Application

  alias Makeup.Registry

  alias Makeup.Lexers.{
    EExLexer,
    HEExLexer,
    ElixirLexer
  }

  def start(_type, _args) do
    ElixirLexer.register_sigil_lexer("H", HEExLexer)

    Registry.register_lexer(EExLexer,
      options: [],
      names: ["eex"],
      extensions: ["eex"]
    )

    Registry.register_lexer(EExLexer,
      options: [outer_lexer: &MakeupEEx.dynamic_html_lexer/0],
      names: ["html_eex", "html.eex"],
      extensions: ["html.eex"]
    )

    Registry.register_lexer(HEExLexer,
      names: ["heex"],
      extensions: ["heex"]
    )

    Supervisor.start_link([], strategy: :one_for_one)
  end
end

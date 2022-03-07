defmodule Makeup.Lexers.EExLexer.Application do
  @moduledoc false
  use Application

  alias Makeup.Registry

  alias Makeup.Lexers.{
    EExLexer,
    HEExLexer,
    HTMLLexer
  }

  def start(_type, _args) do
    Registry.register_lexer(EExLexer,
      options: [],
      names: ["eex"],
      extensions: ["eex"]
    )

    Registry.register_lexer(EExLexer,
      options: [outer_lexer: HTMLLexer],
      names: ["html_eex", "html.eex"],
      extensions: ["html.eex"]
    )

    Registry.register_lexer(HEExLexer,
      options: [],
      names: ["heex"],
      extensions: ["heex"]
    )

    Supervisor.start_link([], strategy: :one_for_one)
  end
end

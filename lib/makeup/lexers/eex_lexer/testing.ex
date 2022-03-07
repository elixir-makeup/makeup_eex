defmodule Makeup.Lexers.EExLexer.Testing do
  @moduledoc false

  alias Makeup.Lexers.{EExLexer, ElixirLexer, HTMLLexer}
  alias Makeup.Lexer.Postprocess

  # These functions have two purposes:
  # 1. Ensure determnistic lexer output (no random prefix)
  # 2. Convert the token values into binaries so that the output
  #    is more obvious on visual inspection
  #    (iolists are hard to parse by a human)

  @spec lex(binary) :: list
  def lex(text) do
    text
    |> EExLexer.lex(group_prefix: "group")
    |> Postprocess.token_values_to_binaries()
    |> Enum.map(fn {ttype, meta, value} -> {ttype, Map.delete(meta, :language), value} end)
  end

  @spec lex_elixir(binary) :: list
  def lex_elixir(text) do
    text
    |> ElixirLexer.lex(group_prefix: "group-ex")
    |> Postprocess.token_values_to_binaries()
    |> Enum.map(fn {ttype, meta, value} -> {ttype, Map.delete(meta, :language), value} end)
  end

  @spec lex_html(any) :: list
  def lex_html(text) do
    text
    |> HTMLLexer.lex(group_prefix: "group-out")
    |> Postprocess.token_values_to_binaries()
    |> Enum.map(fn {ttype, meta, value} -> {ttype, Map.delete(meta, :language), value} end)
  end

  @spec lex_html_eex(any) :: list
  def lex_html_eex(text) do
    text
    |> EExLexer.lex(group_prefix: "group", outer_lexer: HTMLLexer)
    |> Postprocess.token_values_to_binaries()
    |> Enum.map(fn {ttype, meta, value} -> {ttype, Map.delete(meta, :language), value} end)
  end

  @spec lex_heex(any) :: list
  def lex_heex(text) do
    text
    |> EExLexer.lex(group_prefix: "group", outer_lexer: HTMLLexer)
    |> Postprocess.token_values_to_binaries()
    |> Enum.map(fn {ttype, meta, value} -> {ttype, Map.delete(meta, :language), value} end)
  end
end

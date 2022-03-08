defmodule Makeup.Lexers.HEExLexer do
  @moduledoc """
  HEEx lexer
  """

  import NimbleParsec
  alias Makeup.Lexer.Combinators, as: C
  import Makeup.Lexer.Groups

  # By default we'll use the HTMLLexer, but users can provide
  # a different HTML lexer
  alias Makeup.Lexers.{
    ElixirLexer,
    HTMLLexer
  }

  alias Makeup.Lexers.EExLexer.Splicer

  @behaviour Makeup.Lexer

  ###################################################################
  # Step #1: tokenize the input (into a list of tokens)
  ###################################################################

  modified_inline_comment =
    string("#")
    |> concat(
      repeat(
        lookahead_not(
          choice([
            string("\n"),
            string("%>"),
            string("}")
          ])
        )
        |> utf8_char([])
      )
    )
    |> C.token(:comment_single)

  elixir_expr =
    choice([
      modified_inline_comment,
      parsec({ElixirLexer, :root_element})
    ])

  # Make this more strict!
  # we're bound to get a number of false positives due to this.
  # Actually, I should try to find a syntax reference for HEEx
  text_outside_heex =
    times(
      lookahead_not(
        choice([
          string("<%"),
          string("{")
        ])
      )
      |> utf8_char([]),
      min: 1
    )
    |> C.token(:text)
    |> map({__MODULE__, :__as_outside_text__, []})

  def __as_outside_text__({ttype, meta, value}) do
    {ttype, Map.put(meta, :outside_text, true), value}
  end

  # The only thing that makes HEEx templates different from EEx templates
  heex_attrs = C.many_surrounded_by(elixir_expr, "{", "}", :punctuation)

  heex_comment = C.string_like("<%#", "%>", [utf8_char([])], :comment)
  heex_escape = C.many_surrounded_by(elixir_expr, "<%%", "%>", :punctuation)
  heex_show = C.many_surrounded_by(elixir_expr, "<%=", "%>", :punctuation)
  heex_pipe = C.many_surrounded_by(elixir_expr, "<%|", "%>", :punctuation)
  heex_slash = C.many_surrounded_by(elixir_expr, "<%/", "%>", :punctuation)
  heex_exec = C.many_surrounded_by(elixir_expr, "<%", "%>", :punctuation)

  root_element_combinator =
    choice([
      # HEEx attributes
      heex_attrs,
      # EEx expressions
      heex_comment,
      heex_escape,
      heex_show,
      heex_pipe,
      heex_slash,
      heex_exec,
      # Text outside EEx
      text_outside_heex
    ])

  # By default, don't inline the lexers.
  # Inlining them increases performance by ~20%
  # at the cost of doubling the compilation times...
  @inline false

  @doc false

  # If the token is already tagged as belonging to a language, we respect that
  # and don't change the language
  def __as_heex_language__({_ttype, %{language: _}, _value} = token) do
    token
  end

  def __as_heex_language__({ttype, meta, value}) do
    {ttype, Map.put(meta, :language, :heex), value}
  end

  @impl Makeup.Lexer
  defparsec(
    :root_element,
    root_element_combinator |> map({__MODULE__, :__as_heex_language__, []}),
    inline: @inline,
    export_combinator: true
  )

  @impl Makeup.Lexer
  defparsec(
    :root,
    repeat(parsec(:root_element)),
    inline: @inline,
    export_combinator: true
  )

  ###################################################################
  # Step #2: postprocess the list of tokens
  ###################################################################

  # Public API
  @impl Makeup.Lexer
  def postprocess(tokens, _opts \\ []), do: tokens

  ###################################################################
  # Step #3: highlight matching delimiters
  ###################################################################

  @impl Makeup.Lexer
  defgroupmatcher(:match_groups,
    heex_attrs: [
      open: [
        [{:punctuation, %{language: :heex}, "{"}]
      ],
      close: [
        [{:punctuation, %{language: :heex}, "}"}]
      ]
    ],
    heex_comment: [
      open: [
        [{:punctuation, %{language: :heex}, "<%#"}]
      ],
      close: [
        [{:punctuation, %{language: :heex}, "%>"}]
      ]
    ],
    heex_escape: [
      open: [
        [{:punctuation, %{language: :heex}, "<%%"}]
      ],
      close: [
        [{:punctuation, %{language: :heex}, "%>"}]
      ]
    ],
    heex_show: [
      open: [
        [{:punctuation, %{language: :heex}, "<%="}]
      ],
      close: [
        [{:punctuation, %{language: :heex}, "%>"}]
      ]
    ],
    heex_pipe: [
      open: [
        [{:punctuation, %{language: :heex}, "<%|"}]
      ],
      close: [
        [{:punctuation, %{language: :heex}, "%>"}]
      ]
    ],
    heex_slash: [
      open: [
        [{:punctuation, %{language: :heex}, "<%/"}]
      ],
      close: [
        [{:punctuation, %{language: :heex}, "%>"}]
      ]
    ],
    heex_exec: [
      open: [
        [{:punctuation, %{language: :heex}, "<%"}]
      ],
      close: [
        [{:punctuation, %{language: :heex}, "%>"}]
      ]
    ]
  )

  # Finally, the public API for the lexer
  @impl Makeup.Lexer
  def lex(text, opts \\ []) do
    group_prefix = Keyword.get(opts, :group_prefix, random_prefix(10))
    outer_lexer = Keyword.get(opts, :outer_lexer, HTMLLexer)

    # First pass - lex the HEEx part and ignore the outside HTML
    {:ok, tokens, "", _, _, _} = root(text)

    tokens =
      tokens
      |> postprocess([])
      |> ElixirLexer.postprocess([])

    new_group_prefix = group_prefix <> "-out"
    outer_opts = Keyword.put(opts, :group_prefix, new_group_prefix)

    # Second pass - Lex the outside HTML
    all_tokens = Splicer.lex_outside(tokens, outer_lexer, outer_opts)

    # Apply the finishing touches
    all_tokens
    |> match_groups(group_prefix)
    |> ElixirLexer.match_groups(group_prefix <> "-ex")
  end
end

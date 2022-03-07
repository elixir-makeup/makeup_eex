defmodule Makeup.Lexers.EExLexerTest do
  # Test only the EEx part of the lexer.
  # All these examples run without an `:outer_lexer`

  use ExUnit.Case
  import Makeup.Lexers.EExLexer.Testing, only: [lex: 1, lex_elixir: 1]

  test "lex the empty string" do
    assert lex("") == []
  end

  describe "parse elixir inside eex (examples)" do
    test "- module attribute" do
      assert lex("<%= @item %>") == [
               {:punctuation, %{group_id: "group-1"}, "<%="},
               {:whitespace, %{}, " "},
               {:name_attribute, %{}, "@item"},
               {:whitespace, %{}, " "},
               {:punctuation, %{group_id: "group-1"}, "%>"}
             ]
    end

    test "- integer" do
      assert lex("<%= 123 %>") == [
               {:punctuation, %{group_id: "group-1"}, "<%="},
               {:whitespace, %{}, " "},
               {:number_integer, %{}, "123"},
               {:whitespace, %{}, " "},
               {:punctuation, %{group_id: "group-1"}, "%>"}
             ]
    end
  end

  test "parse elixir inside eex" do
    lines = File.read!("test/fixtures/example.exs") |> String.split("\n")

    for marker <- ["", "%", "=", "/", "|"] do
      left_delim = "<%#{marker}"
      right_delim = "%>"

      for line <- lines do
        middle = " " <> line <> " "
        text = left_delim <> middle <> right_delim

        middle_tokens = lex_elixir(middle)
        all_tokens = lex(text)

        left_delim_token = {:punctuation, %{group_id: "group-1"}, left_delim}
        right_delim_token = {:punctuation, %{group_id: "group-1"}, right_delim}

        assert all_tokens == [left_delim_token] ++ middle_tokens ++ [right_delim_token]
      end
    end
  end

  test "parse elixir inside eex with text outside eex" do
    lines = File.read!("test/fixtures/example.exs") |> String.split("\n")

    for marker <- ["", "%", "=", "/", "|"] do
      left_delim = "<%#{marker}"
      right_delim = "%>"

      for line <- lines do
        middle = " " <> line <> " "
        text = "abc " <> left_delim <> middle <> right_delim <> " def"

        middle_tokens = lex_elixir(middle)
        all_tokens = lex(text)

        left_delim_tokens = [
          {:text, %{outside_text: true}, "abc "},
          {:punctuation, %{group_id: "group-1"}, left_delim}
        ]

        right_delim_tokens = [
          {:punctuation, %{group_id: "group-1"}, right_delim},
          {:text, %{outside_text: true}, " def"}
        ]

        assert all_tokens == left_delim_tokens ++ middle_tokens ++ right_delim_tokens
      end
    end
  end
end

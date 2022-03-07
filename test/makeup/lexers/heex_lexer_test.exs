defmodule Makeup.Lexers.HEExLexerTest do
  # Test only the EEx part of the lexer.

  use ExUnit.Case
  import Makeup.Lexers.EExLexer.Testing, only: [lex_heex: 1]

  test "lex the empty string" do
    assert lex_heex("") == []
  end

  test "EEx inside tag" do
    assert lex_heex("<b><%= @username %></b>") == [
             {:punctuation, %{group_id: "group-out-1"}, "<"},
             {:keyword, %{}, "b"},
             {:punctuation, %{group_id: "group-out-1"}, ">"},
             {:punctuation, %{group_id: "group-1"}, "<%="},
             {:whitespace, %{}, " "},
             {:name_attribute, %{}, "@username"},
             {:whitespace, %{}, " "},
             {:punctuation, %{group_id: "group-1"}, "%>"},
             {:punctuation, %{group_id: "group-out-2"}, "</"},
             {:keyword, %{}, "b"},
             {:punctuation, %{group_id: "group-out-2"}, ">"}
           ]
  end

  test "HEEx inside attribute value (the EEx splits the string)" do
    assert lex_heex(~S[<span class="my-<%= @class %>">]) == [
             {:punctuation, %{group_id: "group-out-1"}, "<"},
             {:keyword, %{}, "span"},
             {:whitespace, %{}, " "},
             {:name_attribute, %{}, "class"},
             {:operator, %{}, "="},
             # The bginning of the attribute is highlighted as a string...
             {:string, %{}, "\"my-"},
             # ... then the EEx is properly highlighted as EEx ...
             {:punctuation, %{group_id: "group-1"}, "<%="},
             {:whitespace, %{}, " "},
             {:name_attribute, %{}, "@class"},
             {:whitespace, %{}, " "},
             {:punctuation, %{group_id: "group-1"}, "%>"},
             # ... and finally the remainder of the string is highlighted as a string
             {:string, %{}, "\""},
             {:punctuation, %{group_id: "group-out-1"}, ">"}
           ]
  end

  test "EEx tag" do
    text = "<% end %>\n"

    assert lex_heex(text) == [
             {:punctuation, %{group_id: "group-1"}, "<%"},
             {:whitespace, %{}, " "},
             {:keyword, %{}, "end"},
             {:whitespace, %{}, " "},
             {:punctuation, %{group_id: "group-1"}, "%>"},
             {:whitespace, %{}, "\n"}
           ]
  end

  # @tag skip: true
  test "troublesome case from the Phoenix guides" do
    # This used to raise an error when lexing the outsider text
    # when splitting the sequence of tokens based on the byte offset
    text = """
    <%= if some_condition? do %>
      <p>Some condition is true for user: <%= @username %></p>
    <% else %>
      <p>Some condition is false for user: <%= @username %></p>
    <% end %>
    """

    assert lex_heex(text) == [
             {:punctuation, %{group_id: "group-1"}, "<%="},
             {:whitespace, %{}, " "},
             {:keyword, %{}, "if"},
             {:whitespace, %{}, " "},
             {:name, %{}, "some_condition?"},
             {:whitespace, %{}, " "},
             {:keyword, %{group_id: "group-ex-1"}, "do"},
             {:whitespace, %{}, " "},
             {:punctuation, %{group_id: "group-1"}, "%>"},
             {:whitespace, %{}, "\n  "},
             {:punctuation, %{group_id: "group-out-1"}, "<"},
             {:keyword, %{}, "p"},
             {:punctuation, %{group_id: "group-out-1"}, ">"},
             {:string, %{}, "Some condition is true for user: "},
             {:punctuation, %{group_id: "group-2"}, "<%="},
             {:whitespace, %{}, " "},
             {:name_attribute, %{}, "@username"},
             {:whitespace, %{}, " "},
             {:punctuation, %{group_id: "group-2"}, "%>"},
             {:punctuation, %{group_id: "group-out-2"}, "</"},
             {:keyword, %{}, "p"},
             {:punctuation, %{group_id: "group-out-2"}, ">"},
             {:string, %{}, "\n"},
             {:punctuation, %{group_id: "group-3"}, "<%"},
             {:whitespace, %{}, " "},
             {:keyword, %{group_id: "group-ex-1"}, "else"},
             {:whitespace, %{}, " "},
             {:punctuation, %{group_id: "group-3"}, "%>"},
             {:string, %{}, "\n  "},
             {:punctuation, %{group_id: "group-out-3"}, "<"},
             {:keyword, %{}, "p"},
             {:punctuation, %{group_id: "group-out-3"}, ">"},
             {:string, %{}, "Some condition is false for user: "},
             {:punctuation, %{group_id: "group-4"}, "<%="},
             {:whitespace, %{}, " "},
             {:name_attribute, %{}, "@username"},
             {:whitespace, %{}, " "},
             {:punctuation, %{group_id: "group-4"}, "%>"},
             {:punctuation, %{group_id: "group-out-4"}, "</"},
             {:keyword, %{}, "p"},
             {:punctuation, %{group_id: "group-out-4"}, ">"},
             {:whitespace, %{}, "\n"},
             {:punctuation, %{group_id: "group-5"}, "<%"},
             {:whitespace, %{}, " "},
             {:keyword, %{group_id: "group-ex-1"}, "end"},
             {:whitespace, %{}, " "},
             {:punctuation, %{group_id: "group-5"}, "%>"},
             {:whitespace, %{}, "\n"}
           ]
  end
end

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

  test "HEEx tag" do
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

  test "HEEx with curly braces" do
    assert lex_heex("<b {@attrs}></b>") == [
             {:punctuation, %{group_id: "group-out-1"}, "<"},
             {:keyword, %{}, "b"},
             {:whitespace, %{}, " "},
             {:punctuation, %{group_id: "group-1"}, "{"},
             {:name_attribute, %{}, "@attrs"},
             {:punctuation, %{group_id: "group-1"}, "}"},
             {:punctuation, %{group_id: "group-out-1"}, ">"},
             {:punctuation, %{group_id: "group-out-2"}, "</"},
             {:keyword, %{}, "b"},
             {:punctuation, %{group_id: "group-out-2"}, ">"}
           ]
  end
end

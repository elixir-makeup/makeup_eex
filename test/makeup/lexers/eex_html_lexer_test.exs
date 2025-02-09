defmodule Makeup.Lexers.EExHtmlLexerTest do
  # Test only the EEx part of the lexer.

  use ExUnit.Case
  import Makeup.Lexers.EExLexer.Testing, only: [lex_html_eex: 1, lex_html: 1]

  describe "html-only tests" do
    test "lex the empty string" do
      assert lex_html("") == []
    end

    test "sanity check on the HTML lexer #1" do
      assert lex_html("<input></input>") == [
               {:punctuation, %{group_id: "group-out-1"}, "<"},
               {:name_tag, %{}, "input"},
               {:punctuation, %{group_id: "group-out-1"}, ">"},
               {:punctuation, %{group_id: "group-out-2"}, "</"},
               {:name_tag, %{}, "input"},
               {:punctuation, %{group_id: "group-out-2"}, ">"}
             ]
    end

    test "sanity check on the HTML lexer #2" do
      assert lex_html("<span></span>") == [
               {:punctuation, %{group_id: "group-out-1"}, "<"},
               {:name_tag, %{}, "span"},
               {:punctuation, %{group_id: "group-out-1"}, ">"},
               {:punctuation, %{group_id: "group-out-2"}, "</"},
               {:name_tag, %{}, "span"},
               {:punctuation, %{group_id: "group-out-2"}, ">"}
             ]
    end
  end

  describe "html.eex tests" do
    test "lex the empty string" do
      assert lex_html_eex("") == []
    end

    test "deals with comments" do
      assert lex_html_eex("hello<%!-- comment --%>world") == [
               {:string, %{}, "hello"},
               {:comment, %{}, "<%!-- comment --%>"},
               {:string, %{}, "world"}
             ]
    end

    test "EEx inside tag" do
      assert lex_html_eex("<b><%= @username %></b>") == [
               {:punctuation, %{group_id: "group-out-1"}, "<"},
               {:name_tag, %{}, "b"},
               {:punctuation, %{group_id: "group-out-1"}, ">"},
               {:punctuation, %{group_id: "group-1"}, "<%="},
               {:whitespace, %{}, " "},
               {:name_attribute, %{}, "@username"},
               {:whitespace, %{}, " "},
               {:punctuation, %{group_id: "group-1"}, "%>"},
               {:punctuation, %{group_id: "group-out-2"}, "</"},
               {:name_tag, %{}, "b"},
               {:punctuation, %{group_id: "group-out-2"}, ">"}
             ]
    end

    test "EEx inside attribute value (the EEx splits the string)" do
      assert lex_html_eex(~S[<span class="my-<%= @class %>">]) == [
               {:punctuation, %{group_id: "group-out-1"}, "<"},
               {:name_tag, %{}, "span"},
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

      assert lex_html_eex(text) == [
               {:punctuation, %{group_id: "group-1"}, "<%"},
               {:whitespace, %{}, " "},
               {:keyword, %{}, "end"},
               {:whitespace, %{}, " "},
               {:punctuation, %{group_id: "group-1"}, "%>"},
               {:whitespace, %{}, "\n"}
             ]
    end

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

      assert lex_html_eex(text) == [
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
               {:name_tag, %{}, "p"},
               {:punctuation, %{group_id: "group-out-1"}, ">"},
               {:string, %{}, "Some condition is true for user: "},
               {:punctuation, %{group_id: "group-2"}, "<%="},
               {:whitespace, %{}, " "},
               {:name_attribute, %{}, "@username"},
               {:whitespace, %{}, " "},
               {:punctuation, %{group_id: "group-2"}, "%>"},
               {:punctuation, %{group_id: "group-out-2"}, "</"},
               {:name_tag, %{}, "p"},
               {:punctuation, %{group_id: "group-out-2"}, ">"},
               {:string, %{}, "\n"},
               {:punctuation, %{group_id: "group-3"}, "<%"},
               {:whitespace, %{}, " "},
               {:keyword, %{group_id: "group-ex-1"}, "else"},
               {:whitespace, %{}, " "},
               {:punctuation, %{group_id: "group-3"}, "%>"},
               {:string, %{}, "\n  "},
               {:punctuation, %{group_id: "group-out-3"}, "<"},
               {:name_tag, %{}, "p"},
               {:punctuation, %{group_id: "group-out-3"}, ">"},
               {:string, %{}, "Some condition is false for user: "},
               {:punctuation, %{group_id: "group-4"}, "<%="},
               {:whitespace, %{}, " "},
               {:name_attribute, %{}, "@username"},
               {:whitespace, %{}, " "},
               {:punctuation, %{group_id: "group-4"}, "%>"},
               {:punctuation, %{group_id: "group-out-4"}, "</"},
               {:name_tag, %{}, "p"},
               {:punctuation, %{group_id: "group-out-4"}, ">"},
               {:string, %{}, "\n"},
               {:punctuation, %{group_id: "group-5"}, "<%"},
               {:whitespace, %{}, " "},
               {:keyword, %{group_id: "group-ex-1"}, "end"},
               {:whitespace, %{}, " "},
               {:punctuation, %{group_id: "group-5"}, "%>"},
               {:string, %{}, "\n"}
             ]
    end
  end
end

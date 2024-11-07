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

  test "HEEx tag only" do
    text = "<% end %>"

    assert lex_heex(text) == [
             {:punctuation, %{group_id: "group-1"}, "<%"},
             {:whitespace, %{}, " "},
             {:keyword, %{}, "end"},
             {:whitespace, %{}, " "},
             {:punctuation, %{group_id: "group-1"}, "%>"}
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

  test "bug from the phoenix guides" do
    text =
      ~S[<%= Phoenix.View.render(HelloWeb.PageView, "test.html", message: "Hello from layout!") %>]

    assert lex_heex(text) == [
             {:punctuation, %{group_id: "group-1"}, "<%="},
             {:whitespace, %{}, " "},
             {:name_class, %{}, "Phoenix.View"},
             {:operator, %{}, "."},
             {:name, %{}, "render"},
             {:punctuation, %{group_id: "group-ex-1"}, "("},
             {:name_class, %{}, "HelloWeb.PageView"},
             {:punctuation, %{}, ","},
             {:whitespace, %{}, " "},
             {:string, %{}, "\"test.html\""},
             {:punctuation, %{}, ","},
             {:whitespace, %{}, " "},
             {:string_symbol, %{}, "message"},
             {:punctuation, %{}, ":"},
             {:whitespace, %{}, " "},
             {:string, %{}, "\"Hello from layout!\""},
             {:punctuation, %{group_id: "group-ex-1"}, ")"},
             {:whitespace, %{}, " "},
             {:punctuation, %{group_id: "group-1"}, "%>"}
           ]
  end

  test "HEEx sigil" do
    assert [
             {:string_sigil, _, "~H\"\"\""},
             {:whitespace, _, "\n"},
             {:punctuation, _, "<"},
             {:keyword, _, "div"},
             {:whitespace, _, " "},
             {:name_attribute, _, "class"},
             {:operator, _, "="},
             {:string, _, "\"foo\""},
             {:whitespace, _, " "},
             {:string, _, "bar"},
             {:operator, _, "="},
             {:punctuation, _, "{"},
             {:name_attribute, _, "@baz"},
             {:punctuation, _, "}"},
             {:punctuation, _, ">"},
             {:string, _, "\n  "},
             {:punctuation, _, "<"},
             {:name_class, _, "MyMod"},
             {:operator, _, "."},
             {:name, _, "function"},
             {:whitespace, _, " "},
             {:string, _, "attr"},
             {:operator, _, "="},
             {:string, _, "\"value\""},
             {:whitespace, _, " "},
             {:punctuation, _, "/>"},
             {:whitespace, _, "\n  "},
             {:punctuation, _, "<"},
             {:name_function, _, ".local_component"},
             {:whitespace, _, " "},
             {:string, _, "data-attr"},
             {:punctuation, _, ">"},
             {:string, _, "\n    "},
             {:punctuation, _, "<"},
             {:keyword, _, ":myslot"},
             {:punctuation, _, ">"},
             {:string, _, "SlotContent"},
             {:punctuation, _, "</"},
             {:keyword, _, ":myslot"},
             {:punctuation, _, ">"},
             {:string, _, "\n  "},
             {:punctuation, _, "</"},
             {:name_function, _, ".local_component"},
             {:punctuation, _, ">"},
             {:string, _, "\n"},
             {:punctuation, _, "</"},
             {:keyword, _, "div"},
             {:punctuation, _, ">"},
             {:whitespace, _, "\n"},
             {:string_sigil, _, "\"\"\""},
             {:whitespace, _, "\n"}
           ] =
             Makeup.Lexers.ElixirLexer.lex(~S'''
             ~H"""
             <div class="foo" bar={@baz}>
               <MyMod.function attr="value" />
               <.local_component data-attr>
                 <:myslot>SlotContent</:myslot>
               </.local_component>
             </div>
             """
             ''')
             |> Makeup.Lexer.Postprocess.token_values_to_binaries()
  end
end

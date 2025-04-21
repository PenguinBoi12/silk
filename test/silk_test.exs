defmodule SilkTest do
  use ExUnit.Case
  import Silk

  describe "tag/1 macro" do
    test "handles non-void elements with default empty content" do
      assert tag(:div) == "<div></div>"
      assert tag(:span) == "<span></span>"
      assert tag(:p) == "<p></p>"
    end
  end

  describe "tag/2 macro" do
    test "handles non-void elements with attributes but empty content" do
      assert tag(:div, class: "container") == "<div class=\"container\"></div>"
      assert tag(:span, id: "greeting") == "<span id=\"greeting\"></span>"
    end

    test "treats :do key in attributes as content" do
      assert tag(:p, class: "text", do: "Hello") == "<p class=\"text\">Hello</p>"
      assert tag(:div, do: "Content", id: "main") == "<div id=\"main\">Content</div>"
    end
  end

  describe "content conversion" do
    test "converts various Elixir types to strings" do
      assert tag(:div, do: 123) == "<div>123</div>"
      assert tag(:div, do: true) == "<div>true</div>"
      assert tag(:div, do: :atom) == "<div>atom</div>"
      assert tag(:div, do: nil) == "<div></div>"
      assert tag(:div, do: [1, 2, 3]) == "<div>123</div>"
      assert tag(:div, do: [a: 1]) == "<div>{:a, 1}</div>"
      assert tag(:div, do: {:a, 1}) == "<div>{:a, 1}</div>"
      assert tag(:div, do: %{a: 1}) == "<div>%{a: 1}</div>"
    end
  end

  describe "multi-expression do blocks" do
    test "handles multiple expressions in do block" do
      result = tag :div do
        x = 10
        y = 20

        "Sum: #{x + y}"
      end

      assert result == "<div>Sum: 30</div>"
    end

    test "captures all expressions from a complex do block" do
      result = tag :div do
        prefix = "Items:"
        items = Enum.map(1..3, &"Item #{&1}")

        "#{prefix} #{Enum.join(items, ", ")}"
      end
      
      assert result == "<div>Items: Item 1, Item 2, Item 3</div>"
    end
  end

  describe "tag/3 macro for void elements" do
    test "generates self-closing tags for void elements" do
      assert tag(:aread) == "<aread />"
      assert tag(:base) == "<base />"
      assert tag(:br) == "<br />"
      assert tag(:col) == "<col />"
      assert tag(:embed) == "<embed />"
      assert tag(:hr) == "<hr />"
      assert tag(:img) == "<img />"
      assert tag(:input) == "<input />"
      assert tag(:keygen) == "<keygen />"
      assert tag(:link) == "<link />"
      assert tag(:meta) == "<meta />"
      assert tag(:source) == "<source />"
      assert tag(:track) == "<track />"
      assert tag(:wbr) == "<wbr />"
    end

    test "adds attributes to void elements" do
      result = tag(:input, type: "text", required: true)
      expected = "<input type=\"text\" required=\"true\" />"

      assert result == expected
    end

    test "escapes attributes in void elements" do
      assert tag(:img, alt: "Quote: \"Hello\"") == "<img alt=\"Quote: \"Hello\"\" />"
    end
  end

  describe "tag/3 macro for paired elements" do
    test "generates paired tags with content" do
      assert tag(:p, do: "Hello") == "<p>Hello</p>"
    end

    test "adds attributes to paired elements" do
      assert tag(:p, class: "text", do: "Hello") == "<p class=\"text\">Hello</p>"
    end

    test "handles nested tags" do
      result = tag(:div, class: "outer", do: tag(:p, class: "inner", do: "Text"))
      expected = "<div class=\"outer\"><p class=\"inner\">Text</p></div>"

      assert result == expected
    end

    test "handles multiple nested elements" do
      result = tag :div, class: "container" do
        [
          tag(:h1, do: "Title"),
          tag(:p, do: "Paragraph")
        ]
      end
      expected = "<div class=\"container\"><h1>Title</h1><p>Paragraph</p></div>"

      assert result == expected
    end

    test "handles string interpolation in content" do
      name = "World"
      result = tag(:p, do: "Hello #{name}")
      expected = "<p>Hello World</p>"

      assert result == expected
    end

    test "handles string interpolation in attributes" do
      id = "main"
      result = tag(:div, id: "section-#{id}", do: "Content")
      expected = "<div id=\"section-main\">Content</div>"

      assert result == expected
    end
  end

  describe "tag/3 macro with dynamic content" do
    test "handles lists generated with Enum.map" do
      result = tag :ul do
        Enum.map 1..3, fn i ->
          tag(:li, do: "Item #{i}")
        end
      end
      expected = "<ul><li>Item 1</li><li>Item 2</li><li>Item 3</li></ul>"

      assert result == expected
    end

    test "handles nested dynamic content" do
      result = tag :div, class: "items" do
        Enum.map 1..3, fn i ->
          tag :p, "data-item": "item-#{i}" do
            "Item: #{tag(:b, do: i)}"
          end
        end
      end
      expected = "<div class=\"items\"><p data-item=\"item-1\">Item: <b>1</b></p>" <>
                 "<p data-item=\"item-2\">Item: <b>2</b></p>" <>
                 "<p data-item=\"item-3\">Item: <b>3</b></p></div>"

      assert result == expected
    end
  end

  describe "edge cases" do
    test "handles empty content" do
      assert tag(:div, do: "") == "<div></div>"
    end

    test "handles nil content" do
      assert tag(:div, do: nil) == "<div></div>"
    end

    test "handles integer content" do
      assert tag(:div, do: 42) == "<div>42</div>"
    end

    test "handles boolean attributes" do
      result = tag(:input, type: "checkbox", checked: true)
      expected = "<input type=\"checkbox\" checked=\"true\" />"

      assert result == expected
    end

    test "handles special characters in attributes" do
      result = tag(:a, href: "https://example.com?param=value&other=123", do: "Link")
      expected = "<a href=\"https://example.com?param=value&other=123\">Link</a>"

      assert result == expected
    end
  end
end
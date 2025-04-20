defmodule SilkTest do
  use ExUnit.Case
  import Silk

  describe "tag/3 macro for void elements" do
    test "generates self-closing tags for void elements" do
      assert tag(:br) == "<br />"
      assert tag(:img) == "<img />"
      assert tag(:input) == "<input />"
    end

    test "adds attributes to void elements" do
      assert tag(:img, src: "image.jpg", alt: "An image") == "<img src=\"image.jpg\" alt=\"An image\" />"
      assert tag(:input, type: "text", required: "true") == "<input type=\"text\" required=\"true\" />"
      assert tag(:link, rel: "stylesheet", href: "styles.css") == "<link rel=\"stylesheet\" href=\"styles.css\" />"
    end
    
    test "escapes attributes in void elements" do
      assert tag(:img, alt: "Quote: \"Hello\"") == "<img alt=\"Quote: \\\"Hello\\\"\" />"
    end
  end

  describe "tag/3 macro for paired elements" do
    test "generates paired tags with content" do
      assert tag(:p, do: "Hello") == "<p>Hello</p>"
      assert tag(:div, do: "Content") == "<div>Content</div>"
    end

    test "adds attributes to paired elements" do
      assert tag(:p, class: "text", do: "Hello") == "<p class=\"text\">Hello</p>"
      assert tag(:div, id: "main", class: "container", do: "Content") == 
        "<div id=\"main\" class=\"container\">Content</div>"
    end

    test "handles nested tags" do
      result = tag(:div, class: "outer", do: tag(:p, class: "inner", do: "Text"))
      assert result == "<div class=\"outer\"><p class=\"inner\">Text</p></div>"
    end

    test "handles multiple nested elements" do
      result = tag :div, class: "container" do
        [
          tag(:h1, do: "Title"),
          tag(:p, do: "Paragraph")
        ]
      end
      
      assert result == "<div class=\"container\">Title</div><div class=\"container\">Paragraph</div>"
    end
    
    test "handles string interpolation in content" do
      name = "World"
      result = tag(:p, do: "Hello #{name}")
      assert result == "<p>Hello World</p>"
    end
    
    # test "handles string interpolation in attributes" do
    #   id = "main"
    #   result = tag(:div, id: "section-#{id}", do: "Content")
    #   assert result == "<div id=\"section-main\">Content</div>"
    # end
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
    
    # test "handles nested dynamic content" do
    #   result = tag :div, class: "items" do
    #     Enum.map 1..3, fn i ->
    #       tag :p, "data-item": "item-#{i}" do
    #         "Item: #{tag(:b, do: i)}"
    #       end
    #     end
    #   end
      
    #   expected = "<div class=\"items\"><p data-item=\"item-1\">Item: <b>1</b></p>" <>
    #              "<p data-item=\"item-2\">Item: <b>2</b></p>" <>
    #              "<p data-item=\"item-3\">Item: <b>3</b></p></div>"
    #   assert result == expected
    # end
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
      assert tag(:input, type: "checkbox", checked: true) == 
        "<input type=\"checkbox\" checked=\"true\" />"
    end
    
    test "handles special characters in attributes" do
      assert tag(:a, href: "https://example.com?param=value&other=123", do: "Link") ==
        "<a href=\"https://example.com?param=value&other=123\">Link</a>"
    end
  end
end
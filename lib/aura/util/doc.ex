defmodule Aura.Doc do
  @moduledoc false

  def mod_doc(description, opts \\ []) do
    description = render_description(description)
    example = render_example(opts[:example])
    related = render_related(opts[:related])

    """
    #{description}

    <!-- tabs-open -->
    #{example}

    #{Aura.Doc.resources()}

    #{related}

    <!-- tabs-close -->
    """
  end

  defp render_example(nil), do: ""

  defp render_example(example) do
    """
    ### 💻 Examples

    ```elixir
    #{example}
    ```

    """
  end

  defp render_description(des_list) when is_list(des_list) do
    Enum.map_join(des_list, "\n", fn line ->
      "#{line}\n"
    end)
  end

  defp render_description(des), do: des

  defp render_related(nil), do: ""

  defp render_related(related_list) do
    related_list
    |> Enum.map(fn rel ->
      cleaned = String.replace("#{rel}", "Elixir.", "")
      "`#{cleaned}`"
    end)
    |> related()
  end

  def maintainer_github, do: "👾 [Github: camatcode](https://github.com/camatcode/){:target=\"_blank\"}"

  def maintainer_fediverse,
    do: "🐘 [Fediverse: @scrum_log@maston.social](https://mastodon.social/@scrum_log){:target=\"_blank\"}"

  def contact_maintainer, do: "💬 Contact the maintainer (he's happy to help!)"

  def resources do
    "### 📖 Resources
  * 🐝 Hex
    * #{see_hex_spec()}
    * #{see_hex_core()}
    * #{see_hex_pm()}
  * #{contact_maintainer()}
    * #{maintainer_github()}
    * #{maintainer_fediverse()}
    "
  end

  def controller_doc_link(controller_name) do
    snaked_name = controller_name |> ProperCase.snake_case() |> String.downcase()
    url = "https://github.com/hexpm/hexpm/blob/main/lib/hexpm_web/controllers/api/#{snaked_name}.ex"
    "[#{controller_name}](#{url}){:target=\"_blank\"}"
  end

  def api_details([]), do: ""

  def api_details(route_info) when is_map(route_info), do: api_details([route_info])

  def api_details(route_infos) when is_list(route_infos) do
    header = "### 👩‍💻 API Details "

    table_header =
      String.trim("""
      | Method | Path                  | Controller                                        | Action      |
      |--------|-----------------------|---------------------------------------------------|-------------|
      """)

    table_contents =
      Enum.map_join(route_infos, "\n", fn info ->
        "| #{info.method}    | #{info.route} | #{Aura.Doc.controller_doc_link("#{info.controller}")} | :#{info.action} |"
      end)

    """
    #{header}

    #{table_header}
    #{table_contents}

    """
  end

  defp see_hex_spec do
    see_link("Hex API Specifications", "https://github.com/hexpm/specifications")
  end

  defp see_hex_core do
    see_link("hexpm/hex_core", "https://github.com/hexpm/hex_core", "👾")
  end

  defp see_hex_pm do
    see_link("hexpm/hexpm", "https://github.com/hexpm/hexpm", "👾")
  end

  def see_link(title, url, emoji \\ "📖") do
    "#{emoji} [#{title}](#{url}){:target=\"_blank\"}"
  end

  def related(related_list) do
    header = "### 👀 See Also "

    related_block =
      Enum.map_join(related_list, "\n", fn related ->
        "  * #{related}"
      end)

    """
    #{header}
    #{related_block}
    """
  end

  def returns(success: success, failure: failure) do
    "### ⤵️ Returns

  **✅ On Success**

  ```elixir
  #{success}
  ```
  **❌ On Failure**

   ```elixir
  #{failure}
  ```"
  end

  def returns(success: success) do
    "### ⤵️ Returns

  **✅ On Success**

  ```elixir
  #{success}
  ```
  "
  end
end

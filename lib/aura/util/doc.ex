defmodule Aura.Doc do
  @moduledoc false

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

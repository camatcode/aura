defmodule Aura.Doc do
  @moduledoc false

  def maintainer_github, do: "👾 [Github: camatcode](https://github.com/camatcode/){:target=\"_blank\"}"

  def maintainer_fediverse,
    do: "🐘 [Fediverse: @scrum_log@maston.social](https://mastodon.social/@scrum_log){:target=\"_blank\"}"

  def contact_maintainer, do: "💬 Contact the maintainer (he's happy to help!)"

  def resources do
    "### 📖 Resources
  * #{contact_maintainer()}
    * #{maintainer_github()}
    * #{maintainer_fediverse()}
    "
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

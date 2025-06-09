defmodule Aura.Doc do
  @moduledoc false

  def mod_doc(description, opts \\ []) do
    description = render_description(description)
    example = render_example(opts[:example])
    related = render_related(opts[:related])
    warning = render_warning(opts[:warning])

    """
    #{description}

    #{warning}

    <!-- tabs-open -->
    #{example}

    #{resources()}

    #{related}

    <!-- tabs-close -->
    """
  end

  def type_doc(description, opts \\ []) do
    description = render_description(description)
    keys = render_keys(opts[:keys])
    example = render_example(opts[:example])
    related = render_related(opts[:related])
    warning = render_warning(opts[:warning])

    """
    #{description}

    #{warning}

    <!-- tabs-open -->
    #{keys}

    #{example}

    #{related}

    <!-- tabs-close -->
    """
  end

  def func_doc(description, opts \\ []) do
    description = render_description(description)
    example = render_example(opts[:example])
    related = render_related(opts[:related])
    warning = render_warning(opts[:warning])
    success = opts[:success]
    failure = opts[:failure]
    api_details = render_api_details(opts[:api])
    signature = render_func_sig(opts[:params], success, failure)

    """
    #{description}

    #{warning}

    <!-- tabs-open -->
    #{signature}

    #{example}

    #{api_details}

    #{related}

    <!-- tabs-close -->
    """
  end

  def readme do
    "README.md" |> File.read!() |> String.replace("(#", "(#module-")
  end

  defp render_func_sig(params, success, failure) do
    header = "### 📇 Details"

    table_header =
      String.trim("""
      | Parameter | Description   |
      |--------|-----------------------|
      """)

    table_contents =
      Enum.map_join(params, "\n", fn {k, v} ->
        if String.starts_with?("#{k}", "opts") && "#{k}" != "opts" do
          "| `#{k}`   | #{render_param_value(v)} |"
        else
          "| *#{k}*   | #{render_param_value(v)} |"
        end
      end)

    _returns =
      if success && failure do
        "Returns: <pre>#{success}</pre> or <pre>#{failure}</pre>"
      else
        if success, do: "Returns: <pre>#{success}</pre>", else: ""
      end

    """
    #{header}
      
    #{table_header}
    #{table_contents}


    """
  end

  defp render_api_details(nil), do: ""

  defp render_api_details(m) when is_map(m) do
    method = m[:method] || :GET
    method = String.upcase("#{method}")
    controller = "#{m.controller}"

    controller =
      if String.ends_with?(controller, "Controller") do
        controller
      else
        "#{controller}Controller"
      end

    action = m.action

    route = m.route

    route_infos =
      if m[:repo_scope] do
        [
          %{method: method, action: action, controller: controller, route: route},
          %{method: method, action: action, controller: controller, route: Path.join("/repos/`opts[:repo]`", route)}
        ]
      else
        if m[:org_scope] do
          [
            %{method: method, action: action, controller: controller, route: route},
            %{method: method, action: action, controller: controller, route: Path.join("/orgs/`opts[:org]`", route)}
          ]
        else
          [%{method: method, action: action, controller: controller, route: route}]
        end
      end

    header = "### 👩‍💻 API Details "

    table_header =
      String.trim("""
      | Method | Path                  | Controller                                        | Action      |
      |--------|-----------------------|---------------------------------------------------|-------------|
      """)

    table_contents =
      Enum.map_join(route_infos, "\n", fn info ->
        "| **#{info.method}**    | #{render_route(info.route)} | #{controller_doc_link("#{info.controller}")} | `:#{info.action}` |"
      end)

    """
    #{header}

    #{table_header}
    #{table_contents}

    """
  end

  defp render_route(route) do
    route
    |> Path.split()
    |> Enum.map(fn part ->
      if String.starts_with?(part, ":") do
        "`#{part}`"
      else
        part
      end
    end)
    |> Path.join()
  end

  defp render_warning(nil), do: ""

  defp render_warning({heading, message}) do
    """
    > #### #{heading} {: .warning}
    >
    > #{message}
    """
  end

  defp render_param_value(v) when is_bitstring(v), do: v

  defp render_param_value(v) do
    render_key(v)
  end

  defp render_keys(nil), do: ""

  defp render_keys(m) when is_map(m) do
    header = "### 🏷️ Keys"

    rendered_keys =
      Enum.map_join(m, "\n", fn {k, v} ->
        render_key(k, v)
      end)

    """
    #{header}

    #{rendered_keys}

    """
  end

  defp render_key({mod, name, :list}) do
    cleaned = String.replace("#{mod}", "Elixir.", "")
    "[`t:#{cleaned}.#{name}/0`]"
  end

  defp render_key({mod, name}) do
    cleaned = String.replace("#{mod}", "Elixir.", "")
    "`t:#{cleaned}.#{name}/0`"
  end

  defp render_key(k, {mod, name, :list}) do
    cleaned = String.replace("#{mod}", "Elixir.", "")
    "* **#{k}** :: [`t:#{cleaned}.#{name}/0`]"
  end

  defp render_key(k, {mod, name}) do
    cleaned = String.replace("#{mod}", "Elixir.", "")
    "* **#{k}** :: `t:#{cleaned}.#{name}/0`"
  end

  defp render_key(k, v) do
    cleaned = String.replace("#{v}", "Elixir.", "")
    "* **#{k}** :: `t:#{cleaned}.#{k}/0`"
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

  defp resources do
    "### 📖 Resources
  * 🐝 Hex
    * #{see_hex_spec()}
    * #{see_hex_core()}
    * #{see_hex_pm()}
  * #{contact_maintainer()}
    * #{maintainer_github()}
    * #{see_link("Elixir Form: camatcode", "https://elixirforum.com/u/camatcode/", "⚗️")}
    * #{maintainer_fediverse()}
    * #{see_link("bsky: @ckcook.studiocms.io", "https://bsky.app/profile/ckcook.studiocms.io", "🦋️")}
    "
  end

  defp maintainer_github, do: "👾 [Github: camatcode](https://github.com/camatcode/){:target=\"_blank\"}"

  defp maintainer_fediverse,
    do: "🐘 [Fediverse: @scrum_log@maston.social](https://mastodon.social/@scrum_log){:target=\"_blank\"}"

  defp contact_maintainer, do: "💬 Contact the maintainer (he's happy to help!)"

  defp controller_doc_link(controller_name) do
    snaked_name = controller_name |> ProperCase.snake_case() |> String.downcase()
    url = "https://github.com/hexpm/hexpm/blob/main/lib/hexpm_web/controllers/api/#{snaked_name}.ex"
    "[#{controller_name}](#{url}){:target=\"_blank\"}"
  end

  defp see_hex_spec do
    see_link("Hex API Specifications", "https://github.com/hexpm/specifications")
  end

  defp see_hex_core do
    see_link("Github: hexpm/hex_core", "https://github.com/hexpm/hex_core", "👾")
  end

  defp see_hex_pm do
    see_link("Github: hexpm/hexpm", "https://github.com/hexpm/hexpm", "👾")
  end

  defp see_link(title, url, emoji \\ "📖") do
    "#{emoji} [#{title}](#{url}){:target=\"_blank\"}"
  end

  defp related(related_list) do
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
end

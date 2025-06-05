# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Common do
  @moduledoc """
  Common capabilities across all Aura services

  <!-- tabs-open -->

  #{Aura.Doc.resources()}

  <!-- tabs-close -->
  """

  alias Aura.Requester

  @typedoc """
  A human-readable name for this API key

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "my_computer"
  ```

  <!-- tabs-close -->
  """
  @type api_key_name :: String.t()

  @typedoc """
  The path parameter of the request

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "/packages"
  ```

  <!-- tabs-close -->
  """
  @type api_path :: String.t()

  @typedoc """
  Name of the package

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "plug"
  ```

  <!-- tabs-close -->
  """
  @type package_name :: String.t()

  @typedoc """
  A unique, human-readable ID for a user

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "camatcode"
  ```

  <!-- tabs-close -->
  """
  @type username :: String.t()

  @typedoc """
  An email address associated with this record

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "hello@example.com"
  ```

  <!-- tabs-close -->
  """
  @type email :: String.t()

  @typedoc """
  The version of a release

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "1.2.3"
  ```

  <!-- tabs-close -->
  """
  @type release_version :: String.t()

  @typedoc """
  The name of the repository

  <!-- tabs-open -->

  ### 💻 Examples

  ```elixir
  "hexpm"
  ```

  <!-- tabs-close -->
  """
  @type repo_name :: String.t()

  @doc """
  Implements Hex API's pagination mechanism by returning a `Stream.resource/3`

  <!-- tabs-open -->
  ### 🏷️ Params
    * **path** :: `t:api_path/0`
    * **build_func** :: a function that takes in a map and returns a struct representing what's being paginated
    * **opts** :: option parameters used to modify requests

  #{Aura.Doc.returns(success: "a `Stream.resource/3`")}

  ### 💻 Examples

      iex> alias Aura.Common
      iex> alias Aura.Model.HexPackage
      iex> opts = [repo_url: "http://localhost:4000/api", repo: "hexpm", page: 2, sort: :total_downloads]
      iex> {path, opts} = Common.determine_path(opts, "/packages")
      iex> packages = Common.stream_paginate(path, &HexPackage.build/1, opts)
      iex> Enum.empty?(packages)
      false

  <!-- tabs-close -->
  """
  @spec stream_paginate(path :: api_path(), build_func :: (map() -> map()), opts :: list()) :: Enumerable.t()
  def stream_paginate(path, build_func, opts) do
    qparams =
      Keyword.merge([page: 1, per_page: 1000], opts)

    opts =
      opts
      |> Keyword.delete(:page)
      |> Keyword.delete(:search)
      |> Keyword.delete(:sort)
      |> Keyword.delete(:per_page)

    start_fun = fn -> max(1, qparams[:page]) end
    end_fun = fn _ -> :ok end

    continue_fun = &paginate_with_page(&1, path, qparams, build_func, opts)

    Stream.resource(start_fun, continue_fun, end_fun)
  end

  @doc """
  Determines a `t:api_path/0` by investigating **opts** for a `:repo` key, representing a `Aura.Model.HexRepo`.

  If present, **path** will be modified to scope solely to that repo, otherwise the **path** is unmodified.

  <!-- tabs-open -->
  ### 🏷️ Params
    * **opts** :: option parameters used to modify requests
    * **path** :: `t:api_path/0`

  #{Aura.Doc.returns(success: "{path, opts}")}

  ### 💻 Examples

      iex> alias Aura.Common
      iex> alias Aura.Model.HexPackage
      iex> opts = [repo_url: "http://localhost:4000/api", repo: "hexpm", page: 2, sort: :total_downloads]
      iex> {_path, _opts} = Common.determine_path(opts, "/packages")
      {"/repos/hexpm/packages", [repo_url: "http://localhost:4000/api", page: 2, sort: :total_downloads]}

  <!-- tabs-close -->
  """
  @spec determine_path(opts :: [any()], path :: api_path()) :: {api_path(), [any()]}
  def determine_path(opts, path) do
    if opts[:repo] do
      {Path.join("/repos/#{opts[:repo]}", path), Keyword.delete(opts, :repo)}
    else
      {path, opts}
    end
  end

  defp paginate_with_page(page, _path, _qparams, _build_func, _opts) when page < 1 do
    {:halt, page}
  end

  defp paginate_with_page(page, path, qparams, build_func, opts) when page >= 1 do
    path
    |> get_page(page, qparams, opts)
    |> case do
      {:ok, page_of_items} ->
        items = Enum.map(page_of_items, build_func)
        next_page = if Enum.empty?(items), do: -1, else: page + 1
        {items, next_page}

      # coveralls-ignore-start
      e ->
        {:halt, {:error, e}}
    end

    # coveralls-ignore-stop
  end

  defp get_page(path, page, qparams, opts) do
    qparams = Keyword.put(qparams, :page, page)

    opts = Keyword.put(opts, :qparams, qparams)

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, body}
    end
  end
end

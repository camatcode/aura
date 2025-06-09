# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Releases do
  @moduledoc Aura.Doc.mod_doc("Service module for interacting with Hex package releases")

  import Aura.Common

  alias Aura.Common
  alias Aura.Model.HexRelease
  alias Aura.PackageTarUtil
  alias Aura.Requester

  @packages_path "/packages"
  @dialyzer {:nowarn_function, get_release_docs: 3}

  @typedoc Aura.Doc.type_doc("The reason for retiring a release")
  @type retire_reason :: :renamed | :security | :invalid | :deprecated | :other

  @typedoc Aura.Doc.type_doc("Reporting period for the number of downloads")
  @type download_period :: :day | :month | :all

  @type rel_opts :: [
          repo_url: Aura.Common.repo_url(),
          repo: Aura.Common.repo_name()
        ]

  @type get_rel_opts :: [
          repo_url: Aura.Common.repo_url(),
          repo: Aura.Common.repo_name(),
          downloads: download_period()
        ]

  @doc Aura.Doc.func_doc("Grabs a released package, given its name and version number",
         params: [
           {:package_name, {Aura.Common, :package_name}},
           {:version, {Aura.Common, :release_version}},
           {"opts[:repo]", {Aura.Common, :repo_name}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}},
           {"opts[:downloads]", {Aura.Releases, :download_period}}
         ],
         success: "{:ok, %HexRelease{...}}",
         failure: "{:error, (some error)}",
         api: %{
           route: Path.join(@packages_path, ":package_name/releases/:version"),
           controller: :Release,
           action: :show,
           repo_scope: true
         },
         example: """
         iex> alias Aura.Releases
         iex> repo_url = "http://localhost:4000/api"
         iex> {:ok, postgrex} = Releases.get_release("postgrex", "0.1.0", repo_url: repo_url)
         iex> postgrex.version
         "0.1.0"
         """
       )
  @spec get_release(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: get_rel_opts()
        ) :: {:ok, HexRelease.t()} | {:error, any()}
  def get_release(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}"))
    opts = Keyword.merge([qparams: [downloads: :all]], opts)

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexRelease.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Returns the contents of the release's docs **tar.gz**",
         params: [
           {:package_name, {Aura.Common, :package_name}},
           {:version, {Aura.Common, :release_version}},
           {"opts[:repo]", {Aura.Common, :repo_name}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: "{:ok, [... tar contents ...]}",
         failure: "{:error, (some error)}",
         api: %{
           route: Path.join(@packages_path, ":package_name/releases/:version/docs"),
           controller: :Docs,
           action: :show,
           repo_scope: true
         },
         example: """
         iex> alias Aura.Releases
         iex> repo_url = "http://localhost:4000/api"
         iex> {:ok, contents} = Releases.get_release_docs("jason", "1.4.4", repo_url: repo_url)
         iex> Enum.empty?(contents)
         false
         """
       )
  @spec get_release_docs(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: rel_opts()
        ) :: {:ok, list()} | {:error, any()}
  def get_release_docs(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}/docs"))

    # I dislike putting test carve-outs in main
    # but the test hexpm instance doesn't accurately respond to docs requests
    if Mix.env() == :test do
      :erl_tar.extract("test/support/data/docs/nimble_parsec-1.4.2.tar.gz", [:compressed, :memory])
    else
      with {:ok, %{body: body}} <- Requester.get(path, opts) do
        {:ok, body}
      end
    end
  end

  @doc Aura.Doc.func_doc("Permanently deletes a release",
         params: [
           {:package_name, {Aura.Common, :package_name}},
           {:version, {Aura.Common, :release_version}},
           {"opts[:repo]", {Aura.Common, :repo_name}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: ":ok",
         failure: "{:error, (some error)}",
         api: %{
           method: :delete,
           route: Path.join(@packages_path, ":package_name/releases/:version"),
           controller: :Release,
           action: :delete,
           repo_scope: true
         },
         example: """
         iex> alias Aura.Releases
         iex> repo_url = "http://localhost:4000/api"
         iex> # find a release made by the test framework
         iex> [package] = Enum.take(Packages.stream_packages(sort: :updated_at), 1)
         iex> version = package.releases |> hd() |> Map.get(:version)
         iex> # delete the release
         iex> Releases.delete_release(package.name, version, repo_url: repo_url)
         :ok
         """
       )
  @spec delete_release(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: rel_opts()
        ) :: :ok | {:error, any()}
  def delete_release(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}"))

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  @typedoc Aura.Doc.type_doc("Whether this request is a re-write of a previously published release")
  @type rewrite? :: boolean()

  @type publish_opts :: [replace: rewrite?(), repo_url: Aura.Common.repo_url(), repo: Aura.Common.repo_name()]

  @doc Aura.Doc.func_doc("Publishes a release **.tar** packaged by a build tool to a Hex-compliant repository",
         params: [
           {:release_code_tar, "path to a code .tar file made by a build tool"},
           {"opts[:repo]", {Aura.Common, :repo_name}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}},
           {"opts[:replace]", {Aura.Releases, :rewrite?}}
         ],
         success: "{:ok, %HexRelease{...}}",
         failure: "{:error, (some error)}",
         api: %{method: :post, route: "/publish", controller: :Release, action: :publish, repo_scope: true}
       )
  @spec publish_release(
          release_code_tar :: String.t(),
          opts :: publish_opts()
        ) :: {:ok, HexRelease.t()} | {:error, any()}
  def publish_release(release_code_tar, opts \\ []) when is_bitstring(release_code_tar) do
    {path, opts} = determine_path(opts, "/publish")
    is_rewrite = opts[:replace] == true
    opts = [qparams: [replace: is_rewrite]] |> Keyword.merge(opts) |> Keyword.delete(:replace)

    with {:ok, _streams} <- PackageTarUtil.read_release_tar(release_code_tar) do
      opts = Keyword.merge([body: File.read!(release_code_tar)], opts)

      with {:ok, %{body: body}} <- Requester.post(path, opts) do
        {:ok, HexRelease.build(body)}
      end
    end
  end

  @doc Aura.Doc.func_doc("Publishes associated release docs **tar.gz** to a Hex-compliant repository",
         params: [
           {:package_name, {Aura.Common, :package_name}},
           {:version, {Aura.Common, :release_version}},
           {:doc_tar, "path to a tar.gz of the compiled docs"},
           {"opts[:repo]", {Aura.Common, :repo_name}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: "{:ok, doc_location_url}",
         failure: "{:error, (some error)}",
         api: %{
           method: :post,
           route: Path.join(@packages_path, ":package_name/releases/:release_version/docs"),
           controller: :Docs,
           action: :create,
           repo_scope: true
         },
         example: """
         iex> alias Aura.Releases
         iex> repo_url = "http://localhost:4000/api"
         iex> # find a release made by the test framework
         iex> [package] = Enum.take(Packages.stream_packages(sort: :updated_at), 1)
         iex> version = package.releases |> hd() |> Map.get(:version)
         iex> doc_tar = "test/support/data/docs/nimble_parsec-1.4.2.tar.gz"
         iex> # publish doc tar.gz
         iex> {:ok, _loc} = Releases.publish_release_docs(
         ...>                 package.name,
         ...>                 version,
         ...>                 doc_tar,
         ...>                 repo_url: repo_url)
         """
       )
  @spec publish_release_docs(
          package_name :: Common.package_name(),
          release_version :: Common.release_version(),
          doc_tar :: String.t(),
          opts :: rel_opts()
        ) :: {:ok, URI.t()} | {:error, any()}
  def publish_release_docs(package_name, release_version, doc_tar, opts \\ []) when is_bitstring(doc_tar) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{release_version}/docs"))

    with {:ok, _streams} <- PackageTarUtil.read_release_tar(doc_tar) do
      opts = Keyword.merge([body: File.read!(doc_tar)], opts)

      with {:ok, %{headers: %{"location" => [location]}}} <- Requester.post(path, opts) do
        {:ok, location}
      end
    end
  end

  @doc Aura.Doc.func_doc("Marks a release as **retired**, signaling to others that it should not be used",
         params: [
           {:package_name, {Aura.Common, :package_name}},
           {:version, {Aura.Common, :release_version}},
           {:reason, {Aura.Releases, :retire_reason}},
           {:message, "Human-readable blurb about the retirement"},
           {"opts[:repo]", {Aura.Common, :repo_name}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: ":ok",
         failure: "{:error, (some error)}",
         api: %{
           method: :post,
           route: Path.join(@packages_path, ":package_name/releases/:version/retire"),
           controller: :Retirement,
           action: :create,
           repo_scope: true
         },
         example: """
         iex> alias Aura.Releases
         iex> repo_url = "http://localhost:4000/api"
         iex> # find a release made by the test framework
         iex> [package] = Enum.take(Packages.stream_packages(sort: :updated_at), 1)
         iex> version = package.releases |> hd() |> Map.get(:version)
         iex> reason = :deprecated
         iex> msg = "Release no longer supported"
         iex> # retire the release
         iex> Releases.retire_release(
         ...>          package.name,
         ...>          version,
         ...>          reason,
         ...>          msg,
         ...>          repo_url: repo_url)
         :ok
         """
       )
  @spec retire_release(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          reason :: retire_reason(),
          message :: String.t(),
          opts :: rel_opts()
        ) :: :ok | {:error, any()}
  def retire_release(package_name, version, reason \\ :other, message, opts \\ []) when is_bitstring(message) do
    reason = validate_reason(reason)
    opts = Keyword.merge([json: %{reason: reason, message: message}], opts)
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}/retire"))

    with {:ok, _} <- Requester.post(path, opts) do
      :ok
    end
  end

  @doc Aura.Doc.func_doc(
         "Removes **retirement** from a release, signaling to others that it can still be used",
         params: [
           {:package_name, {Aura.Common, :package_name}},
           {:version, {Aura.Common, :release_version}},
           {"opts[:repo]", {Aura.Common, :repo_name}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: ":ok",
         failure: "{:error, (some error)}",
         api: %{
           method: :delete,
           route: Path.join(@packages_path, ":package_name/releases/:version/retire"),
           controller: :Retirement,
           action: :delete,
           repo_scope: true
         },
         example: """
         iex> alias Aura.Releases
         iex> repo_url = "http://localhost:4000/api"
         iex> # find a release made by the test framework
         iex> [package] = Enum.take(Packages.stream_packages(sort: :updated_at), 1)
         iex> version = package.releases |> hd() |> Map.get(:version)
         iex> # undo the retirement
         iex> Releases.undo_retire_release(
         ...>          package.name,
         ...>          version,
         ...>          repo_url: repo_url)
         :ok
         """
       )
  @spec undo_retire_release(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: rel_opts()
        ) :: :ok | {:error, any()}
  def undo_retire_release(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}/retire"))

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  @doc Aura.Doc.func_doc("Permanently deletes associated documentation for a release",
         params: [
           {:package_name, {Aura.Common, :package_name}},
           {:version, {Aura.Common, :release_version}},
           {"opts[:repo]", {Aura.Common, :repo_name}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: ":ok",
         failure: "{:error, (some error)}",
         api: %{
           method: :delete,
           route: Path.join(@packages_path, ":package_name/releases/:version/docs"),
           controller: :Docs,
           action: :delete,
           repo_scope: true
         },
         example: """
         iex> alias Aura.Releases
         iex> repo_url = "http://localhost:4000/api"
         iex> # find a release made by the test framework
         iex> [package] = Enum.take(Packages.stream_packages(sort: :updated_at), 1)
         iex> version = package.releases |> hd() |> Map.get(:version)
         iex> # delete associated doc tar.gz
         iex> Releases.delete_release_docs(
         ...>           package.name,
         ...>           version,
         ...>           repo_url: repo_url)
         :ok
         """
       )
  @spec delete_release_docs(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: rel_opts()
        ) :: :ok | {:error, any()}
  def delete_release_docs(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}/docs"))

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  defp validate_reason(reason) when is_bitstring(reason) do
    reason
    |> String.downcase()
    |> String.to_atom()
    |> validate_reason()
  end

  defp validate_reason(reason)
       when reason == :renamed or reason == :security or reason == :invalid or reason == :deprecated do
    reason
  end

  defp validate_reason(_), do: :other
end

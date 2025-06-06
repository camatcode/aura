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

  @typedoc """
  The reason for retiring a release
  """
  @type retire_reason :: :renamed | :security | :invalid | :deprecated | :other

  @doc """
  Grabs a released package, given its name and version number

  <!-- tabs-open -->
  ### 🏷️ Params
    * **name** :: `t:Aura.Common.package_name/0`
    * **version** :: `t:Aura.Common.release_version/0`
    * **opts**
      * **repo** :: `t:Aura.Common.repo_name/0`
      * **downloads** :: `:day`, `:month`, `:all`

  #{Aura.Doc.returns(success: "{:ok, %HexRelease{...}}", failure: "{:error, (some error)}")}

  ### 💻 Examples

      iex> alias Aura.Releases
      iex> repo_url = "http://localhost:4000/api"
      iex> {:ok, postgrex} = Releases.get_release("postgrex", "0.1.0", repo_url: repo_url)
      iex> postgrex.version
      "0.1.0"

  ### 👩‍💻 API Details

  | Method | Path                                                      | Controller                                           | Action |
  |--------|-----------------------------------------------------------|------------------------------------------------------|--------|
  | GET    | /api/packages/:package_name/releases/:version             | #{Aura.Doc.controller_doc_link("ReleaseController")} | :show  |
  | GET    | /api/repos/:repo/packages/:package_name/releases/:version | #{Aura.Doc.controller_doc_link("ReleaseController")} | :show  |

  <!-- tabs-close -->
  """
  @spec get_release(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: list()
        ) :: {:ok, HexRelease.t()} | {:error, any()}
  def get_release(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}"))
    opts = Keyword.merge([qparams: [downloads: :all]], opts)

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexRelease.build(body)}
    end
  end

  @doc """
  Returns the contents of the release's docs **tar.gz**

  <!-- tabs-open -->
  ### 🏷️ Params
    * **package_name** :: `t:Aura.Common.package_name/0`
    * **version** :: `t:Aura.Common.release_version/0`
    * **opts**
      * **repo** :: `t:Aura.Common.repo_name/0`

  #{Aura.Doc.returns(success: "{:ok, [... tar contents ...]}", failure: "{:error, (some error)}")}

  ### 💻 Examples

      iex> alias Aura.Releases
      iex> repo_url = "http://localhost:4000/api"
      iex> {:ok, contents} = Releases.get_release_docs("jason", "1.4.4", repo_url: repo_url)
      iex> Enum.empty?(contents)
      false

  ### 👩‍💻 API Details
    
  | Method | Path                                                           | Controller                                        | Action |
  |--------|----------------------------------------------------------------|---------------------------------------------------|--------|
  | GET    | /api/packages/:package_name/releases/:version/docs             | #{Aura.Doc.controller_doc_link("DocsController")} | :show  |
  | GET    | /api/repos/:repo/packages/:package_name/releases/:version/docs | #{Aura.Doc.controller_doc_link("DocsController")} | :show  |

  <!-- tabs-close -->
  """
  @spec get_release_docs(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: list()
        ) :: {:ok, list()} | {:error, any()}
  def get_release_docs(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}/docs"))

    # I dislike putting test carve-outs in main
    # but the local hexpm instance doesn't accurately respond to docs requests
    if Mix.env() == :test do
      :erl_tar.extract("test/support/data/docs/nimble_parsec-1.4.2.tar.gz", [:compressed, :memory])
    else
      with {:ok, %{body: body}} <- Requester.get(path, opts) do
        {:ok, body}
      end
    end
  end

  @doc """
  Permanently deletes a release

  <!-- tabs-open -->
  ### 🏷️ Params
    * **package_name** :: `t:Aura.Common.package_name/0`
    * **version** :: `t:Aura.Common.release_version/0`
    * **opts**
      * **repo** :: `t:Aura.Common.repo_name/0`

  #{Aura.Doc.returns(success: ":ok", failure: "{:error, (some error)}")}

  ### 💻 Examples

      iex> alias Aura.Releases
      iex> repo_url = "http://localhost:4000/api"
      iex> # find a release made by the test framework
      iex> [package] = Enum.take(Packages.stream_packages(sort: :updated_at), 1)
      iex> version = package.releases |> hd() |> Map.get(:version)
      iex> # delete the release
      iex> Releases.delete_release(package.name, version, repo_url: repo_url)
      :ok

  ### 👩‍💻 API Details
    
  | Method | Path                                                      | Controller                                           | Action  |
  |--------|-----------------------------------------------------------|------------------------------------------------------|---------|
  | DELETE | /api/packages/:package_name/releases/:version             | #{Aura.Doc.controller_doc_link("ReleaseController")} | :delete |
  | DELETE | /api/repos/:repo/packages/:package_name/releases/:version | #{Aura.Doc.controller_doc_link("ReleaseController")} | :delete |

  <!-- tabs-close -->
  """
  @spec delete_release(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: list()
        ) :: :ok | {:error, any()}
  def delete_release(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}"))

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  @doc """
  Publishes a release **.tar** packaged by a build tool to a Hex-compliant repository

  <!-- tabs-open -->
  ### 🏷️ Params
    * **release_code_tar** :: path to a code .tar file made by a build tool
    * **opts**
      * **repo** :: `t:Aura.Common.repo_name/0`
      * **replace** :: whether to this request is a re-write

  #{Aura.Doc.returns(success: "{:ok, %HexRelease{...}}", failure: "{:error, (some error)}")}

  ### 👩‍💻 API Details

  | Method | Path                     | Controller                                           | Action   |
  |--------|--------------------------|------------------------------------------------------|----------|
  | POST   | /api/publish             | #{Aura.Doc.controller_doc_link("ReleaseController")} | :publish |
  | POST   | /api/repos/:repo/publish | #{Aura.Doc.controller_doc_link("ReleaseController")} | :publish |

  <!-- tabs-close -->
  """
  @spec publish_release(
          release_code_tar :: String.t(),
          opts :: list()
        ) :: {:ok, HexRelease.t()} | {:error, any()}
  def publish_release(release_code_tar, opts \\ []) when is_bitstring(release_code_tar) do
    {path, opts} = determine_path(opts, "/publish")

    with {:ok, _streams} <- PackageTarUtil.read_release_tar(release_code_tar) do
      opts = Keyword.merge([body: File.read!(release_code_tar)], opts)

      with {:ok, %{body: body}} <- Requester.post(path, opts) do
        {:ok, HexRelease.build(body)}
      end
    end
  end

  @doc """
  Publishes associated release docs **tar.gz** to a Hex-compliant repository

  <!-- tabs-open -->
  ### 🏷️ Params
    * **package_name** :: `t:Aura.Common.package_name/0`
    * **version** :: `t:Aura.Common.release_version/0`
    * **doc_tar** :: path to a tar.gz of the compiled docs
    * **opts**
      * **repo** :: `t:Aura.Common.repo_name/0`

  #{Aura.Doc.returns(success: "{:ok, doc_location_url}", failure: "{:error, (some error)}")}

  ### 💻 Examples

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

  ### 👩‍💻 API Details
    
  | Method | Path                                                           | Controller                                        | Action  |
  |--------|----------------------------------------------------------------|---------------------------------------------------|---------|
  | POST   | /api/packages/:package_name/releases/:version/docs             | #{Aura.Doc.controller_doc_link("DocsController")} | :create |
  | POST   | /api/repos/:repo/packages/:package_name/releases/:version/docs | #{Aura.Doc.controller_doc_link("DocsController")} | :create |

  <!-- tabs-close -->
  """
  @spec publish_release_docs(
          package_name :: Common.package_name(),
          release_version :: Common.release_version(),
          doc_tar :: String.t(),
          opts :: list
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

  @doc """
  Marks a release as **retired**, signaling to others that it should not be used

  <!-- tabs-open -->

  ### 🏷️ Params
    * **package_name** :: `t:Aura.Common.package_name/0`
    * **version** :: `t:Aura.Common.release_version/0`
    * **reason** :: `t:retire_reason/0`
    * **message** :: Human-readable blurb about the retirement
    * **opts**
      * **repo** :: `t:Aura.Common.repo_name/0`

  #{Aura.Doc.returns(success: ":ok", failure: "{:error, (some error)}")}

  ### 💻 Examples

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
    
  ### 👩‍💻 API Details

  | Method | Path                                                             | Controller                                              | Action  |
  |--------|------------------------------------------------------------------|---------------------------------------------------------|---------|
  | POST   | /api/packages/:package_name/releases/:version/retire             | #{Aura.Doc.controller_doc_link("RetirementController")} | :create |
  | POST   | /api/repos/:repo/packages/:package_name/releases/:version/retire | #{Aura.Doc.controller_doc_link("RetirementController")} | :create |

  <!-- tabs-close -->
  """
  @spec retire_release(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          reason :: retire_reason(),
          message :: String.t(),
          opts :: list()
        ) :: :ok | {:error, any()}
  def retire_release(package_name, version, reason \\ :other, message, opts \\ []) when is_bitstring(message) do
    reason = validate_reason(reason)
    opts = Keyword.merge([json: %{reason: reason, message: message}], opts)
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}/retire"))

    with {:ok, _} <- Requester.post(path, opts) do
      :ok
    end
  end

  @doc """
  Removes the **retired** status from a release, signaling to others that it can still be used

  <!-- tabs-open -->

  ### 🏷️ Params
    * **package_name** :: `t:Aura.Common.package_name/0`
    * **version** :: `t:Aura.Common.release_version/0`
    * **opts**
      * **repo** :: `t:Aura.Common.repo_name/0`

  #{Aura.Doc.returns(success: ":ok", failure: "{:error, (some error)}")}

  ### 💻 Examples

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

  ### 👩‍💻 API Details
    
  | Method | Path                                                             | Controller                                              | Action  |
  |--------|------------------------------------------------------------------|---------------------------------------------------------|---------|
  | DELETE | /api/packages/:package_name/releases/:version/retire             | #{Aura.Doc.controller_doc_link("RetirementController")} | :delete |
  | DELETE | /api/repos/:repo/packages/:package_name/releases/:version/retire | #{Aura.Doc.controller_doc_link("RetirementController")} | :delete |

  <!-- tabs-close -->
  """
  @spec undo_retire_release(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: list()
        ) :: :ok | {:error, any()}
  def undo_retire_release(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}/retire"))

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  @doc """
  Permanently deletes associated documentation for a release

  <!-- tabs-open -->
  ### 🏷️ Params
    * **package_name** :: `t:Aura.Common.package_name/0`
    * **version** :: `t:Aura.Common.release_version/0`
    * **opts**
      * **repo** :: `t:Aura.Common.repo_name/0`

  #{Aura.Doc.returns(success: "L:ok", failure: "{:error, (some error)}")}

  ### 💻 Examples

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

  ### 👩‍💻 API Details

  | Method | Path                                                           | Controller                                        | Action  |
  |--------|----------------------------------------------------------------|---------------------------------------------------|---------|
  | DELETE | /api/packages/:package_name/releases/:version/docs             | #{Aura.Doc.controller_doc_link("DocsController")} | :delete |
  | DELETE | /api/repos/:repo/packages/:package_name/releases/:version/docs | #{Aura.Doc.controller_doc_link("DocsController")} | :delete |

  <!-- tabs-close -->
  """
  @spec delete_release_docs(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: list()
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

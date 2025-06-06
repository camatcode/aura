# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Repos do
  @moduledoc Aura.Doc.mod_doc("Service module for interacting with Hex repos")

  alias Aura.Common
  alias Aura.Model.HexAPIKey
  alias Aura.Model.HexRepo
  alias Aura.Requester

  @repos_path "/repos"
  @keys_path "/keys"

  @doc Aura.Doc.func_doc("Grabs hex repos that the user can see",
         params: %{opts: "option parameters used to modify requests"},
         success: "{:ok, [%HexRepo{...}]}",
         failure: "{:error, (some error)}",
         api: %{route: @repos_path, controller: :Repository, action: :index},
         example: """
         iex> alias Aura.Repos
         iex> repo_url = "http://localhost:4000/api"
         iex> {:ok, [hexpm]} = Repos.list_repos(repo_url: repo_url)
         iex> hexpm.name
         "hexpm"
         """
       )
  @spec list_repos(opts :: list()) :: {:ok, [HexRepo.t()]} | {:error, any()}
  def list_repos(opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get(@repos_path, opts) do
      {:ok, Enum.map(body, &HexRepo.build/1)}
    end
  end

  @doc Aura.Doc.func_doc("Grabs info about the requester's API key(s)",
         params: %{opts: "option parameters used to modify requests"},
         success: "{:ok, [%HexAPIKey{...}]}",
         failure: "{:error, (some error)}",
         api: %{route: @keys_path, controller: :Key, action: :index},
         example: """
         iex> alias Aura.Repos
         iex> repo_url = "http://localhost:4000/api"
         iex> {:ok, keys} = Repos.list_api_keys(repo_url: repo_url)
         iex> Enum.empty?(keys)
         false
         """
       )
  @spec list_api_keys(opts :: list()) :: {:ok, [HexAPIKey.t()]} | {:error, any()}
  def list_api_keys(opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get(@keys_path, opts) do
      {:ok, Enum.map(body, &HexAPIKey.build/1)}
    end
  end

  @doc Aura.Doc.func_doc(
         "Grabs a hex repo associated with a given **repo_name**",
         params: %{repo_name: "`t:Aura.Common.repo_name/0`", opts: "option parameters used to modify requests"},
         api: %{route: Path.join(@repos_path, ":repo_name"), controller: :Repository, action: :show},
         example: """
         iex> alias Aura.Repos
         iex> repo_url = "http://localhost:4000/api"
         iex> {:ok, hexpm} = Repos.get_repo("hexpm", repo_url: repo_url)
         iex> hexpm.name
         "hexpm"
         """
       )
  @spec get_repo(repo_name :: Common.repo_name(), opts :: list()) :: {:ok, HexRepo.t()} | {:error, any()}
  def get_repo(repo_name, opts \\ []) when is_bitstring(repo_name) do
    path = Path.join(@repos_path, "#{repo_name}")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexRepo.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Grabs API key information associated with a given **key_name**",
         params: %{key_name: "`t:Aura.Common.api_key_name/0`", opts: "option parameters used to modify requests"},
         success: "{:ok, %HexAPIKey{...}}",
         failure: "{:error, (some error)}",
         api: %{route: Path.join(@keys_path, ":key_name"), controller: :Key, action: :show},
         example: """
         iex> alias Aura.Repos
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> {:ok, keys} = Repos.list_api_keys(opts)
         iex> keys |> Enum.map(fn key ->  {:ok, _k} = Repos.get_api_key(key.name, opts) end)
         """
       )
  @spec get_api_key(key_name :: Common.api_key_name(), opts :: list()) :: {:ok, HexAPIKey.t()} | {:error, any()}
  def get_api_key(key_name, opts \\ []) do
    path = Path.join(@keys_path, "#{key_name}")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexAPIKey.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Creates a new API key",
         params: %{
           key_name: "`t:Aura.Common.api_key_name/0`",
           username: "`t:Aura.Common.username/0`",
           password: "password for this user",
           allow_write: "whether the key has `write` permissions on the `api` domain. Default: `false`",
           opts: "option parameters used to modify requests"
         },
         success: "{:ok, %HexAPIKey{...}}",
         failure: "{:error, (some error)}",
         api: %{method: :post, route: @keys_path, controller: :Key, action: :create}
       )
  @spec create_api_key(
          key_name :: Common.api_key_name(),
          username :: Common.username(),
          password :: String.t(),
          allow_write :: boolean(),
          opts :: list()
        ) :: {:ok, HexAPIKey.t()} | {:error, any()}
  def create_api_key(key_name, username, password, allow_write \\ false, opts \\ []) do
    opts = Keyword.merge([auth: {:basic, "#{username}:#{password}"}], opts)
    read_write = if allow_write, do: [:read, :write], else: [:read]
    permissions = Enum.map(read_write, fn action -> %{domain: :api, resource: action} end)
    opts = Keyword.merge([json: %{name: key_name, permissions: permissions}], opts)

    with {:ok, %{body: body}} <- Requester.post(@keys_path, opts) do
      {:ok, HexAPIKey.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Deletes an API key for the authenticated requester, given a **key_name**",
         params: %{key_name: "`t:Aura.Common.api_key_name/0`", opts: "option parameters used to modify requests"},
         success: ":ok",
         failure: "{:error, (some error)}",
         api: %{method: :delete, route: Path.join(@keys_path, ":key_name"), controller: :Key, action: :delete},
         example: """
         iex> alias Aura.Repos
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> {:ok, [key | _]} = Repos.list_api_keys(opts)
         iex> Repos.delete_api_key(key.name, opts)
         :ok
         """
       )
  @spec delete_api_key(key_name :: Common.api_key_name(), opts :: list()) :: :ok | {:error, any()}
  def delete_api_key(key_name, opts \\ []) do
    path = Path.join(@keys_path, "#{key_name}")

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  @doc Aura.Doc.func_doc("Deletes **all** API keys for the authenticated requester",
         params: %{opts: "option parameters used to modify requests"},
         success: ":ok",
         failure: "{:error, (some error)}",
         api: %{method: :delete, route: @keys_path, controller: :Key, action: :delete_all},
         example: """
         iex> alias Aura.Repos
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> Repos.delete_all_api_keys(opts)
         :ok
         """
       )
  @spec delete_all_api_keys(opts :: list()) :: :ok | {:error, any()}
  def delete_all_api_keys(opts \\ []) do
    path = @keys_path

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end
end

defmodule Aura.APIKeys do
  @moduledoc Aura.Doc.mod_doc("Service module for interacting with Hex API keys")

  import Aura.Common

  alias Aura.Common
  alias Aura.Model.HexAPIKey
  alias Aura.Requester

  @keys_path "/keys"

  @doc Aura.Doc.func_doc("Grabs info about the requester's API key(s)",
         params: %{"opts.org": "`t:Aura.Common.org_name/0`"},
         success: "{:ok, [%HexAPIKey{...}]}",
         failure: "{:error, (some error)}",
         api: %{route: @keys_path, controller: :Key, action: :index, org_scope: true},
         example: """
         iex> alias Aura.APIKeys
         iex> repo_url = "http://localhost:4000/api"
         iex> {:ok, keys} = APIKeys.list_api_keys(repo_url: repo_url)
         iex> Enum.empty?(keys)
         false
         """
       )
  @spec list_api_keys(opts :: list()) :: {:ok, [HexAPIKey.t()]} | {:error, any()}
  def list_api_keys(opts \\ []) do
    {path, opts} = determine_path(opts, @keys_path)

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, Enum.map(body, &HexAPIKey.build/1)}
    end
  end

  @doc Aura.Doc.func_doc("Grabs API key information associated with a given **key_name**",
         params: %{key_name: "`t:Aura.Common.api_key_name/0`", "opts.org": "`t:Aura.Common.org_name/0`"},
         success: "{:ok, %HexAPIKey{...}}",
         failure: "{:error, (some error)}",
         api: %{route: Path.join(@keys_path, ":key_name"), controller: :Key, action: :show, org_scope: true},
         example: """
         iex> alias Aura.APIKeys
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> {:ok, keys} = APIKeys.list_api_keys(opts)
         iex> keys |> Enum.map(fn key ->  {:ok, _k} = APIKeys.get_api_key(key.name, opts) end)
         """
       )
  @spec get_api_key(key_name :: Common.api_key_name(), opts :: list()) :: {:ok, HexAPIKey.t()} | {:error, any()}
  def get_api_key(key_name, opts \\ []) do
    path = Path.join(@keys_path, "#{key_name}")
    {path, opts} = determine_path(opts, path)

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
           "opts.org": "`t:Aura.Common.org_name/0`"
         },
         success: "{:ok, %HexAPIKey{...}}",
         failure: "{:error, (some error)}",
         api: %{method: :post, route: @keys_path, controller: :Key, action: :create, org_scope: true}
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
    {path, opts} = determine_path(opts, @keys_path)

    with {:ok, %{body: body}} <- Requester.post(path, opts) do
      {:ok, HexAPIKey.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Deletes an API key for the authenticated requester, given a **key_name**",
         params: %{key_name: "`t:Aura.Common.api_key_name/0`", "opts.org": "`t:Aura.Common.org_name/0`"},
         success: ":ok",
         failure: "{:error, (some error)}",
         api: %{
           method: :delete,
           route: Path.join(@keys_path, ":key_name"),
           controller: :Key,
           action: :delete,
           org_scope: true
         },
         example: """
         iex> alias Aura.APIKeys
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> {:ok, [key | _]} = APIKeys.list_api_keys(opts)
         iex> APIKeys.delete_api_key(key.name, opts)
         :ok
         """
       )
  @spec delete_api_key(key_name :: Common.api_key_name(), opts :: list()) :: :ok | {:error, any()}
  def delete_api_key(key_name, opts \\ []) do
    path = Path.join(@keys_path, "#{key_name}")
    {path, opts} = determine_path(opts, path)

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  @doc Aura.Doc.func_doc("Deletes **all** API keys for the authenticated requester",
         params: %{opts: "option parameters used to modify requests"},
         success: ":ok",
         failure: "{:error, (some error)}",
         api: %{method: :delete, route: @keys_path, controller: :Key, action: :delete_all, org_scope: true},
         example: """
         iex> alias Aura.APIKeys
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> APIKeys.delete_all_api_keys(opts)
         :ok
         """
       )
  @spec delete_all_api_keys(opts :: list()) :: :ok | {:error, any()}
  def delete_all_api_keys(opts \\ []) do
    {path, opts} = determine_path(opts, @keys_path)

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end
end

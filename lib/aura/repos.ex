defmodule Aura.Repos do
  @moduledoc false

  alias Aura.Model.HexAPIKey
  alias Aura.Model.HexRepo
  alias Aura.Requester

  def list_repos(opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get("/repos", opts) do
      results = Enum.map(body, &HexRepo.build/1)

      {:ok, results}
    end
  end

  def list_api_keys(opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get("/keys", opts) do
      {:ok, Enum.map(body, &HexAPIKey.build/1)}
    end
  end

  def get_repo(repo_name, opts \\ []) when is_bitstring(repo_name) do
    with {:ok, %{body: body}} <- Requester.get("/repos/#{repo_name}", opts) do
      {:ok, HexRepo.build(body)}
    end
  end

  def get_api_key(key_name, opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get("/keys/#{key_name}", opts) do
      {:ok, HexAPIKey.build(body)}
    end
  end

  def create_api_key(key_name, username, password, allow_write \\ false, opts \\ []) do
    opts = Keyword.merge([auth: {:basic, "#{username}:#{password}"}], opts)
    read_write = if allow_write, do: [:read, :write], else: [:read]
    permissions = Enum.map(read_write, fn action -> %{domain: :api, resource: action} end)
    opts = Keyword.merge([json: %{name: key_name, permissions: permissions}], opts)

    with {:ok, %{body: body}} <- Requester.post("/keys/", opts) do
      {:ok, HexAPIKey.build(body)}
    end
  end

  def delete_api_key(key_name, opts \\ []) do
    with {:ok, _} <- Requester.delete("/keys/#{key_name}", opts) do
      :ok
    end
  end
end

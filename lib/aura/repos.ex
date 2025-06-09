# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Repos do
  @moduledoc Aura.Doc.mod_doc("Service module for interacting with Hex repos")

  alias Aura.Common
  alias Aura.Model.HexRepo
  alias Aura.Requester

  @repos_path "/repos"

  @doc Aura.Doc.func_doc("Grabs hex repos that the user can see",
         params: %{opts: "option parameters used to modify requests"},
         success: "{:ok, [%HexRepo{...}]}",
         failure: "{:error, (some error)}",
         api: %{route: @repos_path, controller: :Repository, action: :index},
         example: """
         iex> alias Aura.Repos
         iex> repo_url = "http://localhost:4000/api"
         iex> {:ok, [hexpm |_ ]} = Repos.list_repos(repo_url: repo_url)
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
end

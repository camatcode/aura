defmodule Aura.Repos do
  @moduledoc false

  alias Aura.Model.HexRepo
  alias Aura.Requester

  def get_all_repos do
    with {:ok, %{body: body}} <- Requester.request(:get, "/repos") do
      results =
        body
        |> Enum.map(&HexRepo.build/1)

      {:ok, results}
    end
  end

  def get_repo(repo_name) when is_bitstring(repo_name) do
    with {:ok, %{body: body}} <- Requester.request(:get, "/repos/#{repo_name}") do
      {:ok, HexRepo.build(body)}
    end
  end
end

defmodule Aura.Repos do
  @moduledoc false

  alias Aura.Model.HexRepo
  alias Aura.Requester

  def list_repos do
    with {:ok, %{body: body}} <- Requester.request(:get, "/repos") do
      results = Enum.map(body, &HexRepo.build/1)

      {:ok, results}
    end
  end

  def get_repo(repo_name) when is_bitstring(repo_name) do
    with {:ok, %{body: body}} <- Requester.request(:get, "/repos/#{repo_name}") do
      {:ok, HexRepo.build(body)}
    end
  end
end

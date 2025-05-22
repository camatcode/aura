defmodule Aura.Repos do
  @moduledoc false

  alias Aura.Model.HexRepo
  alias Aura.Requester

  def get_all_repos do
    with {:ok, %{body: body}} <- Requester.request(:get, "/repos") do
      body
      |> Enum.map(fn
        repo ->
          HexRepo.build(repo)
      end)
    end
  end
end

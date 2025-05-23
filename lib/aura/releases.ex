defmodule Aura.Releases do
  @moduledoc false

  alias Aura.Model.HexRelease
  alias Aura.Requester

  def get_release(package_name, version) do
    with {:ok, %{body: body}} <- Requester.get("/packages/#{package_name}/releases/#{version}") do
      {:ok, HexRelease.build(body)}
    end
  end
end

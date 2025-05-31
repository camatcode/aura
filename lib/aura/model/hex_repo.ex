# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexRepo do
  @moduledoc """
  A struct describing a repository from a Hex-compliant API.

  The main Hex.pm public repo is named "hexpm"; though private repos do exist.
  """

  import Aura.Model.Common

  alias Aura.Model.HexRepo

  defstruct [
    :name,
    :public,
    :active,
    :billing_active,
    :inserted_at,
    :updated_at
  ]

  @type t :: term()

  @doc """
  Builds a `HexRepo` from a map
  """
  @spec build(m :: map) :: HexRepo.t()
  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&Kernel.struct(HexRepo, &1))
  end
end

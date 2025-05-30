defmodule Aura.Model.HexPackageMeta do
  @moduledoc false

  import Aura.Model.Common

  alias Aura.Model.HexPackageMeta

  defstruct [
    :maintainers,
    :links,
    :licenses,
    :description
  ]

  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(HexPackageMeta, &1))
  end
end

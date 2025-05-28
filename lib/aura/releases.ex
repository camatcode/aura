defmodule Aura.Releases do
  @moduledoc false

  alias Aura.Model.HexRelease
  alias Aura.Requester

  def get_release(package_name, version, opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get("/packages/#{package_name}/releases/#{version}", opts) do
      {:ok, HexRelease.build(body)}
    end
  end

  def retire_release(package_name, version, reason \\ :other, message, opts \\ []) when is_bitstring(message) do
    reason = validate_reason(reason)

    opts = Keyword.merge([json: %{reason: reason, message: message}], opts)

    with {:ok, _} <- Requester.post("/packages/#{package_name}/releases/#{version}/retire", opts) do
      :ok
    end
  end

  def undo_retire_release(package_name, version, opts \\ []) do
    with {:ok, _} <- Requester.delete("/packages/#{package_name}/releases/#{version}/retire", opts) do
      :ok
    end
  end

  defp validate_reason(reason) when is_bitstring(reason) do
    reason
    |> String.downcase()
    |> String.to_atom()
    |> validate_reason()
  end

  defp validate_reason(reason)
       when reason == :renamed or reason == :security or reason == :invalid or reason == :deprecated do
    reason
  end

  defp validate_reason(_), do: :other
end

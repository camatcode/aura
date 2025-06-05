# SPDX-License-Identifier: Apache-2.0
defmodule Aura.PackageTarUtil do
  @moduledoc Aura.Doc.mod_doc("A utility to read a release tar from a Hex-compliant API")

  @typedoc """
  A mapping between entries of a tar and their bytes
  """
  @type tar_contents :: %{entries: map()}

  @doc """
  Reads a release tar from a given file path
  """
  @spec read_release_tar(tar_path :: String.t()) :: {:ok, tar_contents} | {:error, term()}
  def read_release_tar(tar_path) when is_bitstring(tar_path) do
    with {:ok,
          %{
            entries: entries
          }} <- get_entries(tar_path) do
      streams =
        entries
        |> Enum.map(fn %{file_name: file_name} = entry ->
          %{String.to_atom(file_name) => get_entry_bytes!(tar_path, entry)}
        end)
        |> Enum.reduce(%{}, fn stream, acc ->
          Map.merge(stream, acc)
        end)

      {:ok, streams}
    end
  end

  defp get_entry_bytes!(cbz_file_path, entry) do
    file_name = ~c"#{entry[:file_name]}"

    with {:ok, [{^file_name, data}]} <-
           :erl_tar.extract(cbz_file_path, [
             {:files, [file_name]},
             :compressed,
             :memory
           ]) do
      [:binary.bin_to_list(data)]
    end
  end

  defp get_entries(tar_path, _opts \\ []) do
    with {:ok, file_names} <- :erl_tar.table(tar_path, [:compressed]) do
      file_entries = Enum.map(file_names, &%{file_name: "#{&1}"})

      {:ok, %{entries: file_entries}}
    end
  end
end

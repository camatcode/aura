# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.Common do
  @moduledoc Aura.Doc.mod_doc("Common capabilities across all Aura models")

  @typedoc Aura.Doc.type_doc("Whether the repository is a billable entity")
  @type billing_active :: boolean()

  @typedoc Aura.Doc.type_doc("`DateTime` for when the record was inserted into the database",
             example: """
             ~U[2025-05-29 18:15:18.244790Z]
             """
           )
  @type inserted_at :: DateTime.t()

  @typedoc Aura.Doc.type_doc("URL with human-readable package/release documentation",
             example: """
             "https://hexdocs.pm/aura/0.9.0/"
             """
           )
  @type docs_html_url :: URI.t()

  @typedoc Aura.Doc.type_doc("URL with human-readable package/release information",
             example: """
             "https://hex.pm/packages/aura/0.9.0"
             """
           )
  @type html_url :: URI.t()

  @typedoc Aura.Doc.type_doc("`DateTime` for when the record was last modified in the database",
             example: """
             ~U[2025-06-01 15:13:04.347130Z]
             """
           )
  @type updated_at :: DateTime.t()

  @typedoc Aura.Doc.type_doc("The URL required to perform operations on this record",
             example: """
             "https://hex.pm/api/packages/aura/releases/0.9.0"
             """
           )
  @type url :: URI.t()

  @doc Aura.Doc.func_doc("Cleans and validates a map into something Aura models can easily build",
         params: %{m: "A map to clean and validate"},
         success: "[{k,v}, {k,v}...]",
         failure: "raises Error"
       )
  @spec prepare(m :: map()) :: list()
  def prepare(m) when is_map(m) do
    m
    |> prepare_keys()
    |> prepare_values()
  end

  defp prepare_keys(m) do
    m
    |> snake_case_keys()
    |> atomize_keys()
  end

  defp prepare_values(m) do
    Enum.map(m, fn {key, val} ->
      if val && String.ends_with?("#{key}", "_at"),
        do: {key, DateTimeParser.parse_datetime!(val)},
        else: {key, val}
    end)
  end

  defp snake_case_keys(m) do
    Enum.map(m, fn {key, val} ->
      {ProperCase.snake_case(key), val}
    end)
  end

  defp atomize_keys(m) do
    Enum.map(m, fn {key, val} ->
      key = String.to_atom(key)
      {key, val}
    end)
  end
end

defmodule Aura.Packages do
  @moduledoc false

  alias Aura.Model.HexPackage
  alias Aura.Requester

  def list_packages(opts \\ []) do
    stream_paginate("/packages", opts)
  end

  def get_package(name) do
    with {:ok, %{body: body}} <- Requester.get("/packages/#{name}") do
      {:ok, HexPackage.build(body)}
    end
  end

  defp stream_paginate(path, opts) do
    qparams =
      Keyword.merge([page: 1], opts)

    start_fun = fn -> max(1, qparams[:page]) end
    end_fun = fn _ -> :ok end

    continue_fun = &paginate_with_page(&1, path, qparams)

    Stream.resource(start_fun, continue_fun, end_fun)
  end

  defp paginate_with_page(page, _path, _qparams) when page < 1 do
    {:halt, page}
  end

  defp paginate_with_page(page, path, qparams) when page >= 1 do
    path
    |> get_package_page(page, qparams)
    |> case do
      {:ok, package_page} ->
        packages = Enum.map(package_page, &HexPackage.build/1)
        next_page = if Enum.empty?(packages), do: -1, else: page + 1
        {packages, next_page}

      e ->
        {:halt, {:error, e}}
    end
  end

  defp get_package_page(path, page, qparams) do
    qparams = Keyword.put(qparams, :page, page)

    with {:ok, %{body: body}} <- Aura.Requester.get(path, qparams: qparams) do
      {:ok, body}
    end
  end
end

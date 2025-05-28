defmodule Aura.Packages do
  @moduledoc false

  alias Aura.Model.HexPackage
  alias Aura.Model.HexPackageOwner
  alias Aura.Requester

  def list_packages(opts \\ []) do
    stream_paginate("/packages", opts)
  end

  def list_package_owners(name, opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get("/packages/#{name}/owners", opts) do
      {:ok, Enum.map(body, &HexPackageOwner.build/1)}
    end
  end

  def get_package(name, opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get("/packages/#{name}", opts) do
      {:ok, HexPackage.build(body)}
    end
  end

  defp stream_paginate(path, opts) do
    qparams =
      Keyword.merge([page: 1], opts)

    opts = Keyword.delete(opts, :page)

    start_fun = fn -> max(1, qparams[:page]) end
    end_fun = fn _ -> :ok end

    continue_fun = &paginate_with_page(&1, path, qparams, opts)

    Stream.resource(start_fun, continue_fun, end_fun)
  end

  defp paginate_with_page(page, _path, _qparams, _opts) when page < 1 do
    {:halt, page}
  end

  defp paginate_with_page(page, path, qparams, opts) when page >= 1 do
    path
    |> get_package_page(page, qparams, opts)
    |> case do
      {:ok, package_page} ->
        packages = Enum.map(package_page, &HexPackage.build/1)
        next_page = if Enum.empty?(packages), do: -1, else: page + 1
        {packages, next_page}

      e ->
        {:halt, {:error, e}}
    end
  end

  defp get_package_page(path, page, qparams, opts) do
    qparams = Keyword.put(qparams, :page, page)

    opts = Keyword.put(opts, :qparams, qparams)

    with {:ok, %{body: body}} <- Aura.Requester.get(path, opts) do
      {:ok, body}
    end
  end
end

defmodule Aura.Packages do
  @moduledoc false

  alias Aura.Model.HexPackage
  alias Aura.Model.HexPackageOwner
  alias Aura.Requester

  @base_path "/packages"

  def list_packages(opts \\ []) do
    stream_paginate(@base_path, opts)
  end

  def list_package_owners(name, opts \\ []) do
    path = Path.join(@base_path, "#{name}/owners")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, Enum.map(body, &HexPackageOwner.build/1)}
    end
  end

  def get_package(name, opts \\ []) do
    path = Path.join(@base_path, "#{name}")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexPackage.build(body)}
    end
  end

  def add_package_owner(package_name, owner_email, opts \\ []) do
    encoded_email = URI.encode_www_form(owner_email)
    path = Path.join(@base_path, "#{package_name}/owners/#{encoded_email}")

    with {:ok, _} <- Requester.put(path, opts) do
      :ok
    end
  end

  def remove_package_owner(package_name, owner_email, opts \\ []) do
    encoded_email = URI.encode_www_form(owner_email)
    path = Path.join(@base_path, "#{package_name}/owners/#{encoded_email}")

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  defp stream_paginate(path, opts) do
    qparams =
      Keyword.merge([page: 1], opts)

    opts =
      opts
      |> Keyword.delete(:page)
      |> Keyword.delete(:search)
      |> Keyword.delete(:sort)

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

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, body}
    end
  end
end

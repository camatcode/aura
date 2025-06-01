# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Requester do
  @moduledoc """
  Utility for making HTTP requests to a Hex-compliant API
  """
  require Logger

  @dialyzer {:nowarn_function, user_agent_header: 0}
  @base_url "https://hex.pm/api"

  @typedoc """
  The HTTP method to use for a given request
  """
  @type http_method :: :get | :post | :put | :delete

  @typedoc """
  The path parameter of the request (e.g "/api/packages")
  """
  @type api_path :: String.t()

  @doc """
  Makes a HTTP request
  """
  @spec request(method :: http_method, path :: api_path, opts :: list()) :: {:ok, Req.Response.t()} | {:error, term()}
  def request(method, path, opts \\ []) do
    qparams = opts[:qparams]
    is_retry = opts[:is_retry]
    repo_url = find_repo_url(opts)

    opts =
      opts
      |> Keyword.delete(:qparams)
      |> Keyword.delete(:is_retry)
      |> Keyword.delete(:repo_url)
      |> handle_headers()

    path =
      repo_url
      |> Path.join(path)
      |> handle_qparams(qparams)

    method
    |> make_request(path, opts)
    |> case do
      {:ok,
       %Req.Response{
         status: 200,
         body: _body,
         headers: headers
       }} = resp ->
        respect_limits(headers)
        resp

      {:ok, %Req.Response{status: status, body: _body, headers: headers}} = resp when status >= 200 and status < 300 ->
        respect_limits(headers)
        resp

      {:ok, %Req.Response{status: 429, headers: headers}} ->
        # coveralls-ignore-start
        if is_retry do
          {:error, "Rate limit exceeded"}
        else
          respect_limits(headers)

          new_opts =
            opts
            |> Keyword.put(:is_retry, true)
            |> Keyword.put(:repo_url, repo_url)

          request(method, path, new_opts)
        end

      # coveralls-ignore-stop

      other ->
        {:error, other}
    end
  end

  @doc """
  Makes a HTTP GET request
  """
  @spec get(path :: api_path, opts :: list()) :: {:ok, Req.Response.t()} | {:error, term()}
  def get(path, opts \\ []), do: request(:get, path, opts)

  @doc """
  Makes a HTTP POST request
  """
  @spec post(path :: api_path, opts :: list()) :: {:ok, Req.Response.t()} | {:error, term()}
  def post(path, opts \\ []), do: request(:post, path, opts)

  @doc """
  Makes a HTTP PUT request
  """
  @spec put(path :: api_path, opts :: list()) :: {:ok, Req.Response.t()} | {:error, term()}
  def put(path, opts \\ []), do: request(:put, path, opts)

  # def patch(path, opts \\ []), do: request(:patch, path, opts)

  @doc """
  Makes a HTTP DELETE request
  """
  @spec delete(path :: api_path, opts :: list()) :: {:ok, Req.Response.t()} | {:error, term()}
  def delete(path, opts \\ []), do: request(:delete, path, opts)

  @doc """
  Returns #{@base_url}
  """
  def hex_pm_url, do: @base_url

  @doc """
  Inspects given options, or the `Application.get_env/3` for
    a Hex-compliant API URL
  """
  # coveralls-ignore-start
  @spec find_repo_url(opts :: list()) :: String.t()
  def find_repo_url(repo_url: url), do: url
  # coveralls-ignore-stop

  def find_repo_url(_) do
    Application.get_env(:aura, :repo_url, @base_url)
  end

  defp user_agent_header do
    config = Mix.Project.config()
    app = config[:app] || :unknown
    version = config[:version] || "0.0.0"
    e_version = System.version()
    mix_env = Mix.env()
    user_agent = "#{app}/#{version} (Elixir/#{e_version}) (OTP/#{otp_version()}) (#{mix_env})"
    {"User-Agent", user_agent}
  end

  defp api_key_header(current_opts) do
    if !current_opts[:auth] do
      api_key = current_opts[:api_key] || Application.get_env(:aura, :api_key, nil)
      if api_key, do: {"Authorization", api_key}
    end
  end

  # coveralls-ignore-start
  defp otp_version do
    major = :otp_release |> :erlang.system_info() |> List.to_string()
    vsn_file = Path.join([:code.root_dir(), "releases", major, "OTP_VERSION"])

    try do
      {:ok, contents} = File.read(vsn_file)
      String.split(contents, "\n", trim: true)
    else
      [full] -> full
      _ -> major
    catch
      :error, _ -> major
    end
  end

  # coveralls-ignore-stop

  defp handle_qparams(url, nil), do: url

  defp handle_qparams(url, qparams) do
    qparams =
      qparams
      |> Enum.filter(fn {_k, v} -> v end)
      |> URI.encode_query()

    url
    |> URI.parse()
    |> Map.put(:query, qparams)
    |> URI.to_string()
  end

  defp handle_headers(current_opts) do
    current_headers = Keyword.get(current_opts, :headers, [])
    new_headers = current_headers ++ [user_agent_header()] ++ [api_key_header(current_opts)]
    new_headers = Enum.reject(new_headers, fn t -> t == nil end)
    Keyword.put(current_opts, :headers, new_headers)
  end

  defp make_request(:get, path, opts), do: Req.get(path, opts)
  defp make_request(:post, path, opts), do: Req.post(path, opts)
  defp make_request(:put, path, opts), do: Req.put(path, opts)
  defp make_request(:delete, path, opts), do: Req.delete(path, opts)
  #  defp make_request(:patch, path, opts), do: Req.patch(path, opts)

  # coveralls-ignore-start
  defp respect_limits(%{"x-ratelimit-remaining" => ["0"]} = headers) do
    [reset] = headers["x-ratelimit-reset"] || ["0"]

    unix_reset =
      reset
      |> String.to_integer()
      |> DateTime.from_unix!()

    wait_ms =
      unix_reset
      |> DateTime.diff(DateTime.now!("Etc/UTC"), :millisecond)
      |> max(0)

    Logger.warning("Hit a rate limit, waiting #{wait_ms} milliseconds and retrying.")

    :timer.sleep(wait_ms)
  end

  defp respect_limits(_), do: :ok
  # coveralls-ignore-stop
end

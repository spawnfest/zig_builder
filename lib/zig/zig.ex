defmodule ZigBuilder.Zig do
  @latest_version "0.11.0"
  @moduledoc """
  Documentation for `ZigBuilder`.
  """

  require Logger

  @doc false
  # Latest known version at the time of publishing.
  def latest_version, do: @latest_version

  @doc """
  Returns the configured zig_builder version.
  """
  def configured_version do
    Application.get_env(:zig_builder, :version, latest_version())
  end

  # @doc """
  # Installs zig_builder with `configured_version/0`.
  # """
  # def install() do
  #   fetch!(configured_version())
  # end

  #############################################################################
  ## download zig from online sources.

  # TODO: move to target using :host as a parameter.

  @doc false
  def os_arch do
    "#{get_os()}-#{get_arch()}"
  end

  def get_os do
    case :os.type() do
      {:unix, :linux} ->
        "linux"

      {:unix, :freebsd} ->
        "freebsd"

      {:unix, :darwin} ->
        "macos"

      {_, :nt} ->
        windows_warn()
        "windows"
    end
  end

  @arches %{
    "i386" => "i386",
    "i486" => "i386",
    "i586" => "i386",
    "x86_64" => "x86_64",
    "armv6" => "armv6kz",
    "armv7" => "armv7a",
    "aarch64" => "aarch64",
    "amd64" => "x86_64",
    "win32" => "i386",
    "win64" => "x86_64"
  }

  # note this is the architecture of the machine where compilation is
  # being done, not the target architecture of cross-compiled
  def get_arch do
    arch =
      :system_architecture
      |> :erlang.system_info()
      |> List.to_string()

    Enum.find_value(@arches, fn
      {prefix, zig_arch} -> if String.starts_with?(arch, prefix), do: zig_arch
    end) || raise arch_warn()
  end

  defp arch_warn,
    do: """
      it seems like you are compiling from an unsupported architecture:
        #{:erlang.system_info(:system_architecture)}
      Please leave an issue at https://github.com/ityonemo/zigler/issues
    """

  defp windows_warn do
    raise "windows is not supported, and will be supported in zigler 0.11"
  end

  @zig_dir_path Path.join([File.cwd!(), "_build"])

  def directory, do: Path.join(@zig_dir_path, "zig-#{os_arch()}-#{configured_version()}")

  def fetch!() do
    version = configured_version()
    zig_dir = directory()
    zig_executable = Path.join(zig_dir, "zig")
    :global.set_lock({__MODULE__, self()})

    unless File.exists?(zig_executable) do
      # make sure the zig directory path exists and is ready.
      File.mkdir_p!(@zig_dir_path)

      # make sure that we're in the correct operating system.
      extension =
        if match?({_, :nt}, :os.type()) do
          ".zip"
        else
          ".tar.xz"
        end

      archive = "zig-#{os_arch()}-#{configured_version()}#{extension}"

      zig_download_path = Path.join(@zig_dir_path, archive)
      download_zig_archive(zig_download_path, version, archive)

      # untar the zig directory.
      unarchive_zig(archive)
    else
      Logger.info("Binary already downloaded.")
    end

    :global.del_lock({__MODULE__, self()})
  end

  # https://ziglang.org/download/#release-0.10.1
  # @checksums %{}

  defp download_zig_archive(zig_download_path, version, archive) do
    url = "https://ziglang.org/download/#{version}/#{archive}"
    Logger.info("downloading zig version #{version} (#{url}) and caching in #{@zig_dir_path}.")

    case httpc_get(url) do
      {:ok, %{status: 200, body: body}} ->
        # expected_checksum = Map.fetch!(@checksums, archive)
        # actual_checksum = :sha256 |> :crypto.hash(body) |> Base.encode16(case: :lower)

        # if expected_checksum != actual_checksum do
        #  raise "checksum mismatch: expected #{expected_checksum}, got #{actual_checksum}"
        # end

        File.write!(zig_download_path, body)

      _ ->
        raise "failed to download the appropriate zig archive."
    end
  end

  defp httpc_get(url) do
    {:ok, _} = Application.ensure_all_started(:ssl)
    {:ok, _} = Application.ensure_all_started(:inets)
    headers = []
    request = {String.to_charlist(url), headers}
    http_options = [timeout: 600_000]
    options = [body_format: :binary]

    case :httpc.request(:get, request, http_options, options) do
      {:ok, {{_, status, _}, headers, body}} ->
        {:ok, %{status: status, headers: headers, body: body}}

      other ->
        other
    end
  end

  def unarchive_zig(archive) do
    System.cmd("tar", ["xvf", archive], cd: @zig_dir_path)
  end

  def zig_downloaded?() do
    File.exists?(directory())
  end
end

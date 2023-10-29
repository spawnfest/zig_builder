defmodule ZigBuilder do
  @moduledoc """
  Documentation for `ZigBuilder`.
  """

  use Application
  require Logger
  alias ZigBuilder.Zig

  @doc false
  def start(_, _) do
    unless Application.get_env(:zig_builder, :version) do
      Logger.warning("""
      zig_builder version is not configured. Please set it in your config files:

          config :zig_builder, :version, "#{Zig.latest_version()}"
      """)
    end

    configured_version = Zig.configured_version()

    case Zig.bin_version() do
      {:ok, ^configured_version} ->
        :ok

      {:ok, version} ->
        Logger.warning("""
        Outdated zig_builder version. Expected #{configured_version}, got #{version}. \
        Please run `mix zig.get` or update the version in your config files.\
        """)

      :error ->
        ZigBuilder.Zig.fetch!()
    end

    Supervisor.start_link([], strategy: :one_for_one)
  end

  @doc """
  Hello world.

  ## Examples

      iex> ZigBuilder.hello()
      :world

  """
  def hello do
    :world
  end
end

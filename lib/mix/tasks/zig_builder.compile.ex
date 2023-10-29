defmodule Mix.Tasks.ZigBuilder.Compile do
  use Mix.Task

  @shortdoc "Calls zig build in the root folder"

  alias ZigBuilder.GenerateUtils
  alias ZigBuilder.Zig
  alias ZigBuilder.Compiler

  def run(_args) do
    if !Zig.zig_downloaded?() do
      IO.puts("Zig missing, downloading now...")
      Zig.fetch!()
    end

    Compiler.compile([])
  end
end

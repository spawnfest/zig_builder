defmodule Mix.Tasks.ZigBuilder.Compile do
  use Mix.Task

  @shortdoc "Calls zig build in the root folder"

  alias ZigBuilder.GenerateUtils
  alias ZigBuilder.Zig

  def run(_args) do
    if !Zig.zig_downloaded?() do
      IO.puts("Zig missing, downloading now...")
      Zig.fetch!()
    end

    compile()
  end

  defp compile() do
    exec = Path.join([ZigBuilder.Zig.directory(), "zig"])
    cwd = File.cwd!()
    # build_file_arg = ["--build-file", Path.join([File.cwd!(), "build.zig"])]
    # cache_dir_arg = ["--cache-dir", Path.join(cwd, "zig-cache")]
    # base = exec |> Path.basename() |> Path.rootname()
    args = ["build"] |> List.flatten()

    case GenerateUtils.cmd(exec, args, cwd, [], true, false) do
      0 ->
        zig_build_file = Path.join([cwd, "build.zig"])
        destination = Path.join([File.cwd!(), "build.zig"])

        GenerateUtils.copy_or_override_build_file(zig_build_file, destination)

      exit_status ->
        GenerateUtils.raise_build_error(exec, exit_status, "generation error")
    end

    File.rm_rf(cwd)
  end
end

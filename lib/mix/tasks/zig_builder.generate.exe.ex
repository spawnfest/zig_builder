defmodule Mix.Tasks.ZigBuilder.Generate.Exe do
  use Mix.Task

  @shortdoc "Task for generation of a sample build.zig for executables"

  alias ZigBuilder.GenerateUtils

  def run([]) do
    generate_exe("build.zig")
  end

  def run([name]) do
    generate_exe(name)
  end

  defp generate_exe(_filename) do
    exec = Path.join([ZigBuilder.Zig.directory(), "zig"])

    cwd = Path.join([ZigBuilder.Zig.directory(), "temp"])
    File.rm_rf(cwd)
    File.mkdir_p!(cwd)

    # build_file_arg = ["--build-file", Path.join([File.cwd!(), "build.zig"])]
    cache_dir_arg = ["--cache-dir", Path.join(cwd, "zig-cache")]
    base = exec |> Path.basename() |> Path.rootname()
    args = ["init-exe"] |> List.flatten()

    case GenerateUtils.cmd(exec, args, cwd, [], false) do
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

using PackageCompiler

# 定义要编译的程序入口文件和输出路径
app_source_dir = @__DIR__
app_output_dir = joinpath(@__DIR__, "compiled_app")

# 创建编译配置
create_app(
    app_source_dir,                    # 源代码目录
    app_output_dir;                    # 输出目录
    executables = ["examples/bind_example.jl" => "bind_example"], # 入口文件 => 可执行文件名
    include_transitive_dependencies = true,           # 包含所有依赖
    force = true,                      # 如果输出目录存在则覆盖
    filter_stdlibs = false,           # 包含标准库
) 
using PackageCompiler
create_app(".", "WebViewApp";
    force=true,
    include_lazy_artifacts=true,
    executables=["inline_html.jl" => "inline_html_app"])

# # 方案1：创建更小的系统镜像
# # 只包含最小必需的功能
# using PackageCompiler
# create_sysimage(
#     [:JSON, :HTTP];
#     sysimage_path="minimal.so",
#     precompile_execution_file="bind_example.jl"
# )

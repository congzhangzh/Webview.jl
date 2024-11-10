using PackageCompiler
create_app(".", "dist/WebViewApp";
    force=true,
    include_lazy_artifacts=true,
    executables=["inline_html.jl" => "inline_html_app"])

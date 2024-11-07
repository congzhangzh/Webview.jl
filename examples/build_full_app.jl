using PackageCompiler
create_app(".", "WebViewApp";
    force=true,
    include_lazy_artifacts=true,
    executables=["full_app.jl" => "webview_app"])

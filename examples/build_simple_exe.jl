using PackageCompiler

# 创建一个简单的应用程序
write("app.jl", """
    using WebView
    
    function main()
        # 创建窗口
        wv = Webview(false)
        
        # 设置窗口属性
        set_title(wv, "Packaged WebView App")
        set_size(wv, 800, 600)
        
        # 设置HTML内容
        html = \"\"\"
            <!DOCTYPE html>
            <html>
            <head>
                <title>Hello</title>
            </head>
            <body>
                <h1>Hello from WebView!</h1>
                <button onclick="alert('clicked!')">Click me</button>
            </body>
            </html>
        \"\"\"
        
        navigate(wv, "data:text/html,$(html)")
        
        # 运行
        run(wv)
    end
    
    main()
""")

# 创建可执行文件
create_app(".", "WebViewApp";
    force=true,
    include_lazy_artifacts=true,
    executables=["app.jl" => "webview_app"]) 
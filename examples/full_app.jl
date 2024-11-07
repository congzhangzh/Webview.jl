using WebView

function main()
    # 创建窗口
    wv = Webview(false)
    
    # 设置窗口属性
    set_title(wv, "My WebView App")
    set_size(wv, 800, 600)
    
    # HTML内容
    html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>WebView App</title>
            <style>
                body { 
                    font-family: Arial, sans-serif;
                    margin: 40px;
                    text-align: center;
                }
                button {
                    padding: 10px 20px;
                    font-size: 16px;
                    cursor: pointer;
                }
            </style>
        </head>
        <body>
            <h1>Welcome to WebView App</h1>
            <p>This is a standalone application built with WebView.jl</p>
            <button onclick="showMessage()">Click Me!</button>
            <script>
                function showMessage() {
                    alert('Hello from WebView!');
                }
            </script>
        </body>
        </html>
    """
    
    navigate(wv, "data:text/html,$(html)")
    
    # 运行
    run(wv)
end

main() 
using Webview

function main()
    # 创建窗口
    wv = WebviewObj(false)
    
    # 设置窗口属性
    wv.set_title("My WebView App")
    wv.set_size(800, 600)
    
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
    
    wv.navigate("data:text/html,$(html)")
    
    # 运行
    wv.run()
end

main() 

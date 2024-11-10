#!/usr/bin/env julia

module BindExample

using webview_julia
using JSON
using HTTP

function main()
    # 创建HTML内容
    html = raw"""
    <!DOCTYPE html>
    <html>
    <body>
        <h1>Julia-JavaScript Binding Demo</h1>
        <button onclick="callJulia()">Call Julia</button>
        <button onclick="callJuliaWithArgs(10, 20)">Add Numbers</button>
        <div id="result"></div>

        <script>
            function callJulia() {
                window.julia.hello().then(result => {
                    document.getElementById('result').innerHTML = result;
                });
            }

            function callJuliaWithArgs(a, b) {
                window.julia.add(a, b).then(result => {
                    document.getElementById('result').innerHTML = `Result: ${result}`;
                });
            }

            function updateFromJulia(message) {
                document.getElementById('result').innerHTML = message;
            }
        </script>
    </body>
    </html>
    """

    # 创建webview实例
    w = Webview(true)

    # 定义要从JavaScript调用的Julia函数
    function hello()
        w.eval("updateFromJulia('Hello from Julia!')")
        return "Hello from Julia!"
    end

    function add(req_str)
        args = JSON.parse(req_str)
        result = args[1] + args[2]
        return string(result)
    end

    # 绑定Julia函数
    w.bind("hello", hello)
    w.bind("add", add)

    # 设置窗口属性
    w.set_title("Julia-JavaScript Binding Demo")
    w.set_size(640, 480)

    # 加载HTML内容
    w.navigate("data:text/html," * HTTP.escapeuri(html))

    # 运行webview
    w.run()
end

# 当作为脚本运行时执行main函数
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

end # module 
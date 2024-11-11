#!/usr/bin/env julia

#WIP: https://discourse.julialang.org/t/segfault-with-ccall-when-the-code-is-loaded-as-package/63017
using Webview
#include("../src/webview_julia.jl")
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
            async function callJulia() {
                const result = await window.hello();
                document.getElementById('result').innerHTML = result;
            }

            async function callJuliaWithArgs(a, b) {
                const result = await window.add(a, b);
                document.getElementById('result').innerHTML = `Result: ${result}`;
            }

            function updateFromJulia(message) {
                document.getElementById('result').innerHTML = message;
            }
        </script>
    </body>
    </html>
    """
    # TODO
    # 创建webview实例
    w = WebviewObj(true)

    # 定义要从JavaScript调用的Julia函数
    function hello()
        w.eval("updateFromJulia('Hello from Julia!')")
        return "Hello from Julia!"
    end

    function add(a,b)
        return a + b
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

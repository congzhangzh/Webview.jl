using Downloads
using Libdl

# 导入 FFI 模块的代码
include("../src/ffi.jl")
using .FFI: _ensure_libraries

function download_webview()
    # 直接使用 FFI 中的实现
    try
        libs = _ensure_libraries()
        @info "Successfully downloaded webview libraries: $libs"
    catch e
        @error "Failed to download webview libraries: $e"
        rethrow(e)
    end
end

download_webview() 

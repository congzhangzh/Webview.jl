module Webview

include("ffi.jl")
using .FFI

struct Webview
    handle::Ptr{Cvoid}
    debug::Bool
end

function Webview(debug::Bool = false)
    handle = FFI.webview_create(Int32(debug), C_NULL)
    return Webview(handle, debug)
end

function run(wv::Webview)
    FFI.webview_run(wv.handle)
    destroy(wv)
end

function destroy(wv::Webview)
    FFI.webview_destroy(wv.handle)
end

function set_title(wv::Webview, title::String)
    FFI.webview_set_title(wv.handle, title)
end

function set_size(wv::Webview, width::Integer, height::Integer, hints::Integer = 0)
    FFI.webview_set_size(wv.handle, Int32(width), Int32(height), Int32(hints))
end

function navigate(wv::Webview, url::String)
    FFI.webview_navigate(wv.handle, url)
end

function init(wv::Webview, js::String)
    FFI.webview_init(wv.handle, js)
end

function eval(wv::Webview, js::String)
    FFI.webview_eval(wv.handle, js)
end

# TODO: Implement bind functionality with callback support

end # module 
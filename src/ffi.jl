module FFI

using Libdl

# Load the webview library
const libwebview = Libdl.dlopen("libwebview")  # Updated to use standard library name

# Define functions from the webview library
function webview_create(debug::Int32, window::Ptr{Cvoid})
    ccall((:webview_create, libwebview), Ptr{Cvoid}, (Int32, Ptr{Cvoid}), debug, window)
end

function webview_destroy(handle::Ptr{Cvoid})
    ccall((:webview_destroy, libwebview), Cvoid, (Ptr{Cvoid},), handle)
end

function webview_run(handle::Ptr{Cvoid})
    ccall((:webview_run, libwebview), Cvoid, (Ptr{Cvoid},), handle)
end

function webview_set_title(handle::Ptr{Cvoid}, title::String)
    ccall((:webview_set_title, libwebview), Cvoid, (Ptr{Cvoid}, Cstring), handle, title)
end

function webview_set_size(handle::Ptr{Cvoid}, width::Int32, height::Int32, hints::Int32)
    ccall((:webview_set_size, libwebview), Cvoid, (Ptr{Cvoid}, Int32, Int32, Int32), handle, width, height, hints)
end

function webview_navigate(handle::Ptr{Cvoid}, url::String)
    ccall((:webview_navigate, libwebview), Cvoid, (Ptr{Cvoid}, Cstring), handle, url)
end

function webview_init(handle::Ptr{Cvoid}, js::String)
    ccall((:webview_init, libwebview), Cvoid, (Ptr{Cvoid}, Cstring), handle, js)
end

function webview_eval(handle::Ptr{Cvoid}, js::String)
    ccall((:webview_eval, libwebview), Cvoid, (Ptr{Cvoid}, Cstring), handle, js)
end

function webview_bind(handle::Ptr{Cvoid}, name::String, fn::Ptr{Cvoid}, arg::Ptr{Cvoid})
    ccall((:webview_bind, libwebview), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Cvoid}, Ptr{Cvoid}), handle, name, fn, arg)
end

end # module 
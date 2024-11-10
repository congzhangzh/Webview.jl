module FFI

using Libdl
using Downloads

function _get_webview_version()
    # Get webview version from environment or use default
    get(ENV, "WEBVIEW_VERSION", "0.8.1")
end

function _get_lib_names()
    if Sys.iswindows()  # 更简单的系统判断
        if Sys.ARCH === :x86_64  # 检查是否是64位
            return ["webview.dll", "WebView2Loader.dll"]
        else
            error("32-bit Windows is not supported")
        end
    elseif Sys.isapple()  # macOS
        if Sys.ARCH === :aarch64
            return ["libwebview.aarch64.dylib"]
        else
            return ["libwebview.x86_64.dylib"]
        end
    elseif Sys.islinux()  # Linux
        return ["libwebview.so"]
    else
        error("Unsupported operating system")
    end
end

function _get_download_urls()
    version = _get_webview_version()
    return ["https://github.com/webview/webview_deno/releases/download/$version/$lib_name" 
            for lib_name in _get_lib_names()]
end

function _ensure_libraries()
    # Determine base directory for libraries
    base_dir = dirname(@__FILE__)
    lib_dir = joinpath(base_dir, "lib")
    
    lib_names = _get_lib_names()
    lib_paths = [joinpath(lib_dir, lib_name) for lib_name in lib_names]
    
    # Check if any library is missing
    missing = filter(path -> !isfile(path), lib_paths)
    isempty(missing) && return lib_paths
    
    # Create lib directory if it doesn't exist
    mkpath(lib_dir)
    
    # Download missing libraries
    urls = _get_download_urls()
    for (url, lib_path) in zip(urls, lib_paths)
        isfile(lib_path) && continue
        
        @info "Downloading library from $url"
        try
            Downloads.download(url, lib_path)
        catch e
            error("Failed to download library: $e")
        end
    end
    
    return lib_paths
end

# Load the webview library
const libwebview_path = let
    lib_paths = _ensure_libraries()
    first_lib_path = first(lib_paths)
    @info "Loading library from: $first_lib_path"
    
    if !isfile(first_lib_path)
        error("Library file does not exist: $first_lib_path")
    end
    
    first_lib_path
    # handle = try
    #     Libdl.dlopen(first_lib, Libdl.RTLD_GLOBAL)
    # catch e
    #     error("Failed to load library $first_lib: $e")
    # end
    
    # if handle == C_NULL
    #     error("Library handle is null after loading $first_lib")
    # end
    
    # handle
end

# Define functions from the webview library
function webview_create(debug::Int32, window::Ptr{Cvoid})
    ccall((:webview_create, libwebview_path), Ptr{Cvoid}, (Int32, Ptr{Cvoid}), debug, window)
end

function webview_destroy(handle::Ptr{Cvoid})
    ccall((:webview_destroy, libwebview_path), Cvoid, (Ptr{Cvoid},), handle)
end

function webview_run(handle::Ptr{Cvoid})
    ccall((:webview_run, libwebview_path), Cvoid, (Ptr{Cvoid},), handle)
end

function webview_set_title(handle::Ptr{Cvoid}, title::String)
    ccall((:webview_set_title, libwebview_path), Cvoid, (Ptr{Cvoid}, Cstring), handle, title)
end

function webview_set_size(handle::Ptr{Cvoid}, width::Int32, height::Int32, hints::Int32)
    ccall((:webview_set_size, libwebview_path), Cvoid, (Ptr{Cvoid}, Int32, Int32, Int32), handle, width, height, hints)
end

function webview_navigate(handle::Ptr{Cvoid}, url::String)
    ccall((:webview_navigate, libwebview_path), Cvoid, (Ptr{Cvoid}, Cstring), handle, url)
end

function webview_init(handle::Ptr{Cvoid}, js::String)
    ccall((:webview_init, libwebview_path), Cvoid, (Ptr{Cvoid}, Cstring), handle, js)
end

function webview_eval(handle::Ptr{Cvoid}, js::String)
    ccall((:webview_eval, libwebview_path), Cvoid, (Ptr{Cvoid}, Cstring), handle, js)
end

function webview_bind(handle::Ptr{Cvoid}, name::String, fn::Ptr{Cvoid}, arg::Ptr{Cvoid})
    ccall((:webview_bind, libwebview_path), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Cvoid}, Ptr{Cvoid}), handle, name, fn, arg)
end

function webview_terminate(handle::Ptr{Cvoid})
    ccall((:webview_terminate, libwebview_path), Cvoid, (Ptr{Cvoid},), handle)
end

end # module 

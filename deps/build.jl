using Downloads
using Libdl

function download_webview()
    @static if Sys.iswindows()
        url = "https://github.com/webview/webview/releases/latest/download/webview.dll"
        filename = "webview.dll"
    elseif Sys.isapple()
        url = "https://github.com/webview/webview/releases/latest/download/libwebview.dylib"
        filename = "libwebview.dylib"
    else
        url = "https://github.com/webview/webview/releases/latest/download/libwebview.so"
        filename = "libwebview.so"
    end

    dest = joinpath(@__DIR__, "..", "deps", filename)
    mkpath(dirname(dest))
    
    try
        Downloads.download(url, dest)
        @info "Successfully downloaded webview library to $dest"
    catch e
        @error "Failed to download webview library: $e"
        rethrow(e)
    end
end

download_webview() 
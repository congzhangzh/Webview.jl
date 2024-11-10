module webview_julia

include("ffi.jl")
using .FFI

export Webview

# 保存回调函数的引用，改用复合key防止冲突
const CALLBACKS = Dict{Tuple{Ptr{Cvoid}, String}, Function}()

# 回调函数的C兼容包装器
function callback_c_wrapper(seq::Ptr{Cvoid}, req::Ptr{Cchar}, arg::Ptr{Cvoid})::Cvoid
    req_str = unsafe_string(req)
    if haskey(CALLBACKS, arg)
        try
            CALLBACKS[arg](req_str)
        catch e
            @error "Error in callback" exception=e
        end
    end
    return nothing
end

const C_CALLBACK = @cfunction(callback_c_wrapper, Cvoid, (Ptr{Cvoid}, Ptr{Cchar}, Ptr{Cvoid}))

mutable struct Webview
    handle::Ptr{Cvoid}
    debug::Bool
    
    function Webview(debug::Bool = false)
        handle = FFI.webview_create(Int32(debug), C_NULL)
        w = new(handle, debug)
        finalizer(w) do x
            # 只在对象没有正确关闭时作为后备清理机制
            if x.handle != C_NULL  # 检查handle是否已经被close清理
                @warn "Webview was not properly closed, cleaning up in finalizer"
                close(x)
            end
        end
        return w
    end
end

function Base.getproperty(self::Webview, sym::Symbol)
    if sym === :run
        return () -> (FFI.webview_run(self.handle); self.destroy())
    elseif sym === :destroy
        return () -> FFI.webview_destroy(self.handle)
    elseif sym === :set_title
        return (title) -> FFI.webview_set_title(self.handle, title)
    elseif sym === :set_size
        return (width, height, hints=0) -> FFI.webview_set_size(self.handle, Int32(width), Int32(height), Int32(hints))
    elseif sym === :navigate
        return (url) -> FFI.webview_navigate(self.handle, url)
    elseif sym === :init
        return (js) -> FFI.webview_init(self.handle, js)
    elseif sym === :eval
        return (js) -> FFI.webview_eval(self.handle, js)
    elseif sym === :bind
        return (name::String, callback::Function) -> begin
            # 使用(handle, name)作为复合key来存储回调
            CALLBACKS[(self.handle, name)] = callback
            FFI.webview_bind(self.handle, name, C_CALLBACK, name)
        end
    else
        return getfield(self, sym)
    end
end

# 确保在Webview被销毁时清理回调
function Base.close(self::Webview)
    if self.handle == C_NULL  # 已经关闭
        return
    end
    
    # 清理该实例相关的所有回调
    for key in keys(CALLBACKS)
        if key[1] == self.handle
            delete!(CALLBACKS, key)
        end
    end
    
    self.destroy()
    self.handle = C_NULL  # 标记为已关闭
end

function with_webview(f::Function, debug::Bool=false)
    w = Webview(debug)
    try
        f(w)
    finally
        close(w)
    end
end

# # 基本用法
# with_webview() do w
#     w.set_title("Test")
#     w.navigate("https://example.com")
#     w.run()  # 需要显式调用 run
# end

# 或者创建一个更高级的包装
function run_webview(f::Function, debug::Bool=false)
    with_webview(debug) do w
        f(w)
        w.run()  # 自动调用 run
    end
end

# # 使用更简洁的包装
# run_webview() do w
#     w.set_title("Test")
#     w.navigate("https://example.com")
# end  # 自动调用 run 和 close

end # module 

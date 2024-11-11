module webview_julia

include("ffi.jl")
using .FFI
using JSON

export Webview

# 定义一个可变类型来存储回调相关数据
mutable struct CallbackData
    handle::Ptr{Cvoid}
    name::String
    callback::Function
end

# 使用简单的字典存储回调数据
const CALLBACKS = Dict{Tuple{Ptr{Cvoid}, String}, CallbackData}()

# 回调函数的C兼容包装器
function callback_c_wrapper(seq::Ptr{Cchar}, req::Ptr{Cchar}, arg::Ptr{Cvoid})::Cvoid
    seq_str = unsafe_string(seq)
    req_str = unsafe_string(req)
    
    # debug:
    println("callback_c_wrapper: seq_str = $seq_str, req_str = $req_str, arg = $arg")
    # 恢复可变对象 - 得到的是引用，指向同一个对象
    data = unsafe_pointer_to_objref(arg)::CallbackData
    
    try
        args = JSON.parse(req_str)
        result = data.callback(args...)  # 直接使用恢复的对象即可
        
        if result isa Task
            @async begin
                try
                    final_result = fetch(result)
                    result_json = JSON.json(final_result)
                    FFI.webview_return(data.handle, seq_str, Int32(0), result_json)
                catch e
                    FFI.webview_return(data.handle, seq_str, Int32(1), string(e))
                end
            end
        else
            result_json = JSON.json(result)
            FFI.webview_return(data.handle, seq_str, Int32(0), result_json)
        end
    catch e
        FFI.webview_return(data.handle, seq_str, Int32(1), string(e))
    end
    
    return nothing
end


function test_callback(seq::Ptr{Cchar}, req::Ptr{Cchar}, arg::Ptr{Cvoid})::Cvoid
    seq_str = unsafe_string(seq)
    req_str = unsafe_string(req)
    println("test_callback: seq_str = $seq_str, req_str = $req_str, arg = $arg")
end

# why so trick:
#   https://docs.julialang.org/en/v1/manual/modules/
#   https://discourse.julialang.org/t/segfault-with-ccall-when-the-code-is-loaded-as-package/63017
const C_CALLBACK_REF = Ref(C_NULL)
function __init__()
    C_CALLBACK_REF[] = @cfunction(callback_c_wrapper, Cvoid, (Ptr{Cchar}, Ptr{Cchar}, Ptr{Cvoid}))
end

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
            key = (self.handle, name)
            # 创建可变对象存储数据
            data = CallbackData(self.handle, name, callback)
            # 先存储到字典中，确保数据不会被GC
            CALLBACKS[key] = data
            # 使用已存储在字典中的对象创建指针
            arg_ref = pointer_from_objref(CALLBACKS[key])
            FFI.webview_bind(self.handle, name, C_CALLBACK_REF[], arg_ref)

        end
    elseif sym === :unbind
        return (name::String) -> begin
            handle_and_name = (self.handle, name)
            if haskey(CALLBACKS, handle_and_name)
                delete!(CALLBACKS, handle_and_name)
                FFI.webview_unbind(self.handle, name)
            end
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

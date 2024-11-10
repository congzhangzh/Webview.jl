using webview_julia:Webview
using Test

@testset "WebView.jl" begin
    # 方法1：使用 @testset 和 skip
    @testset "Platform tests" begin
        if Sys.isapple()
            @info "Skipping tests on Apple platform"
        else
            # Basic creation test
            wv = WebView(false)
            @test wv.handle != C_NULL
            @test wv.debug == false
            
            # Test setters
            wv.set_title("Test Window")
            wv.set_size(800, 600)
            
            # Clean up
            wv.destroy()
        end
    end
end 
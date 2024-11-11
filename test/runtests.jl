using Webview
using Test

@testset "WebView.jl" begin
    @testset "Platform tests" begin
        if Sys.isapple()
            @info "Skipping tests on Apple platform"
        else
            # Basic creation test
            wv = WebviewObj(false)
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
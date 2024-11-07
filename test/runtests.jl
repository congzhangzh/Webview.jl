using WebView
using Test

@testset "WebView.jl" begin
    # Basic creation test
    wv = WebView(false)
    @test wv.handle != C_NULL
    @test wv.debug == false
    
    # Test setters
    set_title(wv, "Test Window")
    set_size(wv, 800, 600)
    
    # Clean up
    destroy(wv)
end 
# WebView.jl

[![Build Status](https://github.com/yourusername/WebView.jl/workflows/CI/badge.svg)](https://github.com/yourusername/WebView.jl/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Julia bindings for the [webview](https://github.com/webview/webview) library, allowing you to create desktop applications with web technologies.

## Installation

```julia
using Pkg
Pkg.add("WebView")
```

## Usage

### Display Inline HTML:
```julia
using WebView

html = """
<!DOCTYPE html>
<html>
    <body>
        <h1>Hello from Julia Webview!</h1>
    </body>
</html>
"""

webview = Webview()
navigate(webview, "data:text/html,$(html)")
run(webview)
```

### Load Remote URL:
```julia
using WebView

webview = Webview()
navigate(webview, "https://julialang.org")
run(webview)
```

### Julia-JavaScript Bindings:
```julia
using WebView

webview = Webview(true)  # Enable debug mode

# Julia functions that can be called from JavaScript
function hello()
    println("Hello from Julia!")
    return "Hello from JavaScript!"
end

function add(a, b)
    return a + b
end

# HTML content with JavaScript
html = """
<!DOCTYPE html>
<html>
<body>
    <h1>Julia-JavaScript Binding Demo</h1>
    <button onclick="hello()">Call Julia</button>
    <button onclick="add(1, 2)">Calculate 1 + 2</button>
</body>
</html>
"""

# Configure window
set_title(webview, "Binding Demo")
set_size(webview, 800, 600)

navigate(webview, "data:text/html,$(html)")
run(webview)
```

### Creating Standalone Executable:
```julia
using PackageCompiler

create_app(".", "WebViewApp";
    force=true,
    include_lazy_artifacts=true,
    executables=["app.jl" => "webview_app"])
```

## Features

- 🚀 Create desktop applications using HTML, CSS, and JavaScript
- 📂 Load local HTML files or remote URLs
- 🔄 Bidirectional Julia-JavaScript communication
- 🖼️ Window size and title customization
- 🐛 Debug mode for development
- 💻 Cross-platform support (Windows, macOS, Linux)
- 📦 Standalone executable creation

## Development

### Project Structure
```
WebView.jl/
├── src/
│   ├── WebView.jl    # Main implementation
│   └── ffi.jl        # Foreign Function Interface
├── examples/         # Example applications
├── test/            # Unit tests
└── README.md        # Documentation
```

### Running Tests
```julia
] test WebView
```

### Release Process

1. **Test**
```bash
# Run tests
julia -e 'using Pkg; Pkg.test("WebView")'

# Build documentation
julia --project=docs/ docs/make.jl
```

2. **Update Version in Project.toml**
```toml
version = "x.y.z"
```

3. **Create Release**
```bash
# Tag version
git tag vx.y.z
git push origin vx.y.z
```

## Examples

Check the `examples/` directory for more examples:
- Basic window creation
- JavaScript interaction
- Custom HTML content
- Standalone application
- Window management

## Roadmap

- [x] Basic webview functionality
- [x] Julia-JavaScript bindings
- [x] Standalone executable support
- [ ] Prebuilt binaries for all platforms
- [ ] More comprehensive examples
- [ ] Documentation website
- [ ] Hot reload support
- [ ] Custom window decorations

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

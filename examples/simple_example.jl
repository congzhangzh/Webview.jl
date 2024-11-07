using Webview

# Create a new webview instance
wv = Webview(true)  # debug mode enabled

# Set window properties
set_title(wv, "My Webview App")
set_size(wv, 800, 600)

# Load content
navigate(wv, "https://julialang.org")

# Run the webview
run(wv) 
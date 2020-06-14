module engine.window;

import bindbc.glfw;

import std.string;

alias WindowFramebufferSizeCallback = extern (C) void function(GLFWwindow*, int, int) nothrow;

struct WindowConfig
{
    string title;
    uint   width;
    uint   height;

    WindowFramebufferSizeCallback framebufferSizeCallback;
}

struct Window
{
private:
    GLFWwindow* _window;

public:
    this(WindowConfig config)
    {
        _window = glfwCreateWindow(config.width, config.height, config.title.toStringz, null, null);
        assert(_window, "Failed to Create GLFW Window.");

        if (config.framebufferSizeCallback)
        {
            setFramebufferSizeCallback(config.framebufferSizeCallback);
        }
    }

    void makeContextCurrent()
    {
        glfwMakeContextCurrent(_window);
    }

    void setFramebufferSizeCallback(WindowFramebufferSizeCallback callback)
    {
        glfwSetFramebufferSizeCallback(_window, callback);
    }

    void swapBuffers()
    {
        glfwSwapBuffers(_window);
    }

    int getKey(int key)
    {
        return glfwGetKey(_window, key);
    }

    @property
    bool shouldClose()
    {
        return cast(bool) glfwWindowShouldClose(_window);
    }

    @property
    void shouldClose(bool value)
    {
        glfwSetWindowShouldClose(_window, value);
    }
}

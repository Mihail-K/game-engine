module engine.window;

import bindbc.glfw;

import std.string;

import utils.matrix;

alias WindowKeyCallback             = extern (C) void function(GLFWwindow*, int, int, int, int) nothrow;
alias WindowFramebufferSizeCallback = extern (C) void function(GLFWwindow*, int, int) nothrow;

struct WindowConfig
{
    string title;
    int    width;
    int    height;
}

struct WindowDimension
{
    int width;
    int height;
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
    }

    this(GLFWwindow* window) nothrow
    {
        _window = window;
    }

    @property
    WindowDimension dimensions()
    {
        // int width, height;

        // glfwGetFramebufferSize(_window, &width, &height);

        // return WindowDimension(width, height);

        return WindowDimension(800, 600);
    }

    @property
    Mat4 projection()
    {
        auto dimensions = this.dimensions;

        return Mat4.orthographic(0, dimensions.width, 0, dimensions.height, -1, 1);
    }

    void makeContextCurrent()
    {
        glfwMakeContextCurrent(_window);
    }

    void setKeyCallback(WindowKeyCallback callback)
    {
        glfwSetKeyCallback(_window, callback);
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
    bool shouldClose() nothrow
    {
        return cast(bool) glfwWindowShouldClose(_window);
    }

    @property
    void shouldClose(bool value) nothrow
    {
        glfwSetWindowShouldClose(_window, value);
    }
}

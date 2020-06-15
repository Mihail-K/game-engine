import std.stdio;

import bindbc.glfw;
import bindbc.opengl;
import bindbc.freetype;

import imagefmt;

import engine.game_engine;
import engine.shader;
import engine.texture;
import engine.window;

void main()
{
	prepareGLFW();

	scope (exit)
	{
		glfwTerminate();
	}

	WindowConfig windowConfig = {
		title: "Test Window",
		width: 800,
		height: 600
	};

	Window window = Window(windowConfig);
	window.makeContextCurrent();

	prepareOpenGL();
	window.setKeyCallback!(keyCallback);
	window.setFramebufferSizeCallback!(framebufferSizeCallback);

	glViewport(0, 0, windowConfig.width, windowConfig.height);

	GameEngine gameEngine = GameEngine(window);
	gameEngine.initialize();

	float delta = 0.0;
	float lastFrame = 0.0;

	while (!window.shouldClose)
	{
		float currentFrame = glfwGetTime();

		delta     = currentFrame - lastFrame;
		lastFrame = currentFrame;

        glfwPollEvents();

		gameEngine.processInput(delta);
		gameEngine.update(delta);

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        gameEngine.render();

		window.swapBuffers();
	}

	writeln("Done.");
}

private void keyCallback(Window window, int key, int scancode, int action, int mode) nothrow
{
	if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
	{
		window.shouldClose = true;
	}
}

private void framebufferSizeCallback(Window window, int width, int height) nothrow
{
	glViewport(0, 0, width, height);
}

void prepareGLFW()
{
	GLFWSupport result = loadGLFW();

    switch (result)
    {
        case GLFWSupport.badLibrary:
            assert(0, "Bad library");

        case GLFWSupport.noLibrary:
            assert(0, "Missing GLFW.");

        default:
            writefln("Loaded GLFW (%s)", result);
    }

    glfwInit();

    glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_API);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);

    glfwSetErrorCallback(&appGlobalErrorHandler);
}

private extern (C) void appGlobalErrorHandler(int code, const(char)* message) nothrow
{
    printf("Error(%d, 0x%x): %s\n", code, code, message);
}

void prepareOpenGL()
{
	GLSupport result = loadOpenGL();

    switch (result)
    {
        case GLSupport.badLibrary:
            assert(0, "Bad library");

        case GLSupport.noLibrary:
            assert(0, "Missing OpenGL.");

        default:
            writefln("Loaded OpenGL (%s)", result);
    }

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

void prepareFreeType()
{
	FTSupport result = loadFreeType("freetype.dll");

    switch (result)
    {
        case FTSupport.badLibrary:
            assert(0, "Bad library");

        case FTSupport.noLibrary:
            assert(0, "Missing FreeType.");

        default:
            writefln("Loaded FreeType (%s)", result);
    }
}

import std.stdio;

import bindbc.glfw;
import bindbc.opengl;
import bindbc.freetype;

import imagefmt;

import engine.game;
import engine.shader;
import engine.texture;
import engine.window;

immutable string vertexShaderSource = q{
	#version 330 core

	layout (location = 0) in vec3 aPos;
	layout (location = 1) in vec3 aColor;
	layout (location = 2) in vec2 aTexCoord;

	out vec3 ourColor;
	out vec2 texCoord;

	void main()
	{
		gl_Position = vec4(aPos, 1.0);
		ourColor    = aColor;
		texCoord    = aTexCoord;
	}
};

immutable string fragmentShaderSource = q{
	#version 330 core

	in vec3 ourColor;
	in vec2 texCoord;

	out vec4 fragColor;

	uniform sampler2D texture1;
	uniform sampler2D texture2;

	void main()
	{
		fragColor = mix(texture(texture1, texCoord), texture(texture2, vec2(texCoord.x, 1.0 - texCoord.y)), 0.2);
	}
};

immutable float[] vertices = [
    // positions          // colors           // texture coords
     0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // top right
     0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // bottom right
    -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // bottom left
    -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f    // top left 
];

immutable float[] texCoords = [
	0.0f, 0.0f,
	1.0f, 0.0f,
	0.5f, 1.0f
];

immutable uint[] indices = [
    0, 1, 3,   // first triangle
    1, 2, 3   // second triangle
];

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
	window.setKeyCallback(&keyCallback);
	window.setFramebufferSizeCallback(&framebufferSizeCallback);

	Game game;
	game.initialize();

	float delta;
	float lastFrame;

	while (!window.shouldClose)
	{
		float currentFrame = glfwGetTime();

		delta     = currentFrame - lastFrame;
		lastFrame = currentFrame;

        glfwPollEvents();

		game.processInput(delta);
		game.update(delta);

        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        game.render();

		window.swapBuffers();
	}

	writeln("Done.");
}

private extern (C) void keyCallback(GLFWwindow* glfwWindow, int key, int scancode, int action, int mode) nothrow
{
	Window window = Window(glfwWindow);

	if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
	{
		window.shouldClose = true;
	}
}

private extern (C) void framebufferSizeCallback(GLFWwindow* window, int width, int height) nothrow
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

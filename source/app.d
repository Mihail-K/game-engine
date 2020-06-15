import std.stdio;

import bindbc.glfw;
import bindbc.opengl;
import bindbc.freetype;

import imagefmt;

import game_engine.core;
import game_engine.utils;

class TestGameState : GameState
{
	@property
	override GameStateID gameStateID() const
	{
		return defaultGameStateID;
	}

	override void setup(GameContainer container)
	{
        TextureConfig textureConfig = { internalFormat: GL_RGBA };

        container.resourceManager.createTexture("face", "assets/face.png", textureConfig);
	}

	override void render(GameContainer container)
	{
        SpriteConfig spriteConfig = {
            texture:  container.resourceManager.fetchTexture("face"),
            position: Vec2(0, 0),
            size:     Vec2(300, 400),
            rotate:   0,
            color:    Vec3(1, 0.8, 0.8)
        };

        container.spriteRenderer.drawSprite(spriteConfig);
	}
}

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

	GameEngine gameEngine;

	gameEngine.initWindow(windowConfig);
	gameEngine.initGraphicsLibrary();
	gameEngine.initGameEngine();

	gameEngine.window.setKeyCallback!(keyCallback);
	gameEngine.window.setFramebufferSizeCallback!(framebufferSizeCallback);

	gameEngine.addGameState(new TestGameState());
	gameEngine.setGameState(defaultGameStateID);
	gameEngine.start();

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

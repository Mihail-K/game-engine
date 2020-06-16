import std.stdio;

import bindbc.glfw;
import bindbc.opengl;

import imagefmt;

import game_engine;

class TestGameState : GameState
{
	Font font;

	@property
	override GameStateID gameStateID() const
	{
		return defaultGameStateID;
	}

	override void setup(GameContainer container)
	{
        TextureConfig textureConfig = { internalFormat: GL_RGBA };

        container.resourceManager.createTexture("face", "assets/face.png", textureConfig);

		container.window.setKeyCallback!(keyCallback);
		container.window.setFramebufferSizeCallback!(framebufferSizeCallback);

		FontConfig fontConfig = { path: "assets/consola.ttf" };
		font = new Font(fontConfig);

		foreach (ch; 0..128)
		{
			font.loadChar(cast(char) ch);
		}
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

        container.renderer.drawSprite(spriteConfig);

		TextConfig textConfig = {
			font:     font,
			position: Vec2(300, 100),
			color:    Vec3(0.75, 0.33, 0.95)
		};

		container.renderer.drawText("Left Beef", textConfig);
	}
}

void main()
{
	WindowConfig windowConfig = {
		title: "Test Window",
		width: 800,
		height: 600
	};

	auto game = new Game();

	game.initWindow(windowConfig);
	game.initGraphicsLibrary();
	game.initGameEngine();

	game.addGameState(new TestGameState());
	game.setGameState(defaultGameStateID);
	game.start();

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

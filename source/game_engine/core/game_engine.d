module game_engine.core.game_engine;

import bindbc.glfw;
import bindbc.opengl;

import game_engine.core.game_container;
import game_engine.core.game_state;
import game_engine.core.resource_manager;
import game_engine.core.shader;
import game_engine.core.sprite_renderer;
import game_engine.core.texture;
import game_engine.core.window;
import game_engine.utils.vector;

struct GameEngine
{
private:
    GameStateID            _currentGameStateID = defaultGameStateID;
    GameState[GameStateID] _gameStates;
    Window                 _window;
    ResourceManager        _resourceManager;
    SpriteRenderer         _renderer = void;

public:
    void initWindow(WindowConfig config)
    {
        _window = Window(config);
        _window.makeContextCurrent();
    }

    void initGraphicsLibrary()
    {
        assert(window.ready, "Window has not been initialized!");
        auto dimensions = window.dimensions;

        prepareOpenGL();
	    glViewport(0, 0, dimensions.width, dimensions.height);
    }

    void initGameEngine()
    {
        initResourceManager();
        initSpriteRenderer();
    }

    void addGameState(GameState gameState)
    {
        _gameStates[gameState.gameStateID] = gameState;
    }

    @property
    GameState currentGameState()
    {
        auto ptr = _currentGameStateID in _gameStates;

        return ptr ? *ptr : null;
    }

    void setGameState(GameStateID gameStateID)
    {
        auto current = currentGameState;
        auto future  = _gameStates[gameStateID];

        if (current)
        {
            current.teardown(gameContainer);
        }

        future.setup(gameContainer);
    }

    void start()
    {        
        float delta     = 0.0;
        float lastFrame = 0.0;

        while (!window.shouldClose)
        {
            float currentFrame = glfwGetTime();

            delta     = currentFrame - lastFrame;
            lastFrame = currentFrame;

            auto gameState = currentGameState;
            assert(gameState, "No current Game State!");

            glfwPollEvents();

            gameState.processInput(gameContainer, delta);
            gameState.update(gameContainer, delta);

            glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
            glClear(GL_COLOR_BUFFER_BIT);

            gameState.render(gameContainer);
            window.swapBuffers();
        }
    }

    @property
    Window window()
    {
        return _window;
    }

private:
    void initResourceManager()
    {
        _resourceManager = new ResourceManager();
    }

    void initSpriteRenderer()
    {
        ShaderConfig[] shaderConfigs = [
            {
                code: import("sprite.vert"),
                type: GL_VERTEX_SHADER
            },
            {
                code: import("sprite.frag"),
                type: GL_FRAGMENT_SHADER
            }
        ];

        auto spriteShader = _resourceManager.createShader("sprite", shaderConfigs);

        spriteShader.use();
        spriteShader.setInt("image", 0);
        spriteShader.setMatrix4("projection", window.projection);

        _renderer = SpriteRenderer(spriteShader);
    }

    private GameContainer gameContainer()
    {
        return GameContainer(_resourceManager, _renderer);
    }
}

private void prepareOpenGL()
{
	GLSupport result = loadOpenGL();

    switch (result)
    {
        case GLSupport.badLibrary:
            assert(0, "Bad library");

        case GLSupport.noLibrary:
            assert(0, "Missing OpenGL.");

        default:
            import std.stdio : writefln; // TODO: Use Logger.
            writefln("Loaded OpenGL (%s)", result);
    }

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

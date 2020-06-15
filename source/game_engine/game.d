module game_engine.game;

import bindbc.glfw;
import bindbc.opengl;

import game_engine.core;
import game_engine.ecs.entity_manager;
import game_engine.ecs.system_manager;
import game_engine.utils.vector;

class Game
{
private:
    GameStateID            _currentGameStateID = defaultGameStateID;
    GameState[GameStateID] _gameStates;
    Window                 _window;
    ResourceManager        _resourceManager;
    EntityManager          _entityManager;
    SystemManager          _systemManager;
    Renderer               _renderer = void;

public:
    this()
    {
        prepareGLFW();
    }

    ~this()
    {
        glfwTerminate();
    }

    void initWindow(WindowConfig config)
    {
        _window = Window(config);
        _window.makeContextCurrent();
    }

    void initGraphicsLibrary()
    {
        assert(_window.ready, "Window has not been initialized!");
        auto dimensions = _window.dimensions;

        prepareOpenGL();
	    glViewport(0, 0, dimensions.width, dimensions.height);
    }

    void initGameEngine()
    {
        _resourceManager = new ResourceManager();
        _entityManager   = new EntityManager();
        _systemManager   = new SystemManager();
        _renderer        = createRenderer();
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

        while (!_window.shouldClose)
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
            _window.swapBuffers();
        }
    }

private:
    private GameContainer gameContainer()
    {
        return GameContainer(_resourceManager, _entityManager, _systemManager, _renderer, _window);
    }

    private Renderer createRenderer()
    {
        return Renderer(createSpriteRenderer());
    }

    private SpriteRenderer createSpriteRenderer()
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
        spriteShader.setMatrix4("projection", _window.projection);

        return SpriteRenderer(spriteShader);
    }
}

private void prepareGLFW()
{
	GLFWSupport result = loadGLFW();

    switch (result)
    {
        case GLFWSupport.badLibrary:
            assert(0, "Bad library");

        case GLFWSupport.noLibrary:
            assert(0, "Missing GLFW.");

        default:
            import std.stdio : writefln; // TODO: Use Logger.
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

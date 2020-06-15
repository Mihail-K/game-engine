module game_engine.core.game_engine;

import bindbc.opengl;

import game_engine.core.resource_manager;
import game_engine.core.shader;
import game_engine.core.sprite_renderer;
import game_engine.core.texture;
import game_engine.core.window;
import game_engine.utils.vector;

enum GameState
{
    active,
    menu,
    victory
}

struct GameEngine
{
private:
    GameState       _state;
    Window          _window;
    ResourceManager _resourceManager;
    SpriteRenderer  _renderer = void;

public:
    @disable this();

    this(Window window)
    {
        _window = window;
    }

    void initialize()
    {
        ShaderConfig[] shaderConfigs = [
            {
                path: "source/game_engine/shaders/sprite.vert",
                type: GL_VERTEX_SHADER
            },
            {
                path: "source/game_engine/shaders/sprite.frag",
                type: GL_FRAGMENT_SHADER
            }
        ];

        auto spriteShader = _resourceManager.createShader("sprite", shaderConfigs);

        spriteShader.use();
        spriteShader.setInt("image", 0);
        spriteShader.setMatrix4("projection", window.projection);

        _renderer = SpriteRenderer(spriteShader);

        TextureConfig textureConfig = {
            internalFormat: GL_RGBA
        };

        _resourceManager.createTexture("face", "assets/face.png", textureConfig);
    }

    void processInput(float delta)
    {

    }

    void update(float delta)
    {

    }

    void render()
    {
        SpriteConfig spriteConfig = {
            texture:  _resourceManager.fetchTexture("face"),
            position: Vec2(0, 0),
            size:     Vec2(300, 400),
            rotate:   0,
            color:    Vec3(1, 0.8, 0.8)
        };

        _renderer.drawSprite(spriteConfig);
    }

    @property
    Window window()
    {
        return _window;
    }
}

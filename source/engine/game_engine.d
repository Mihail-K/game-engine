module engine.game_engine;

import bindbc.opengl;

import engine.resource_manager;
import engine.shader;
import engine.sprite_renderer;
import engine.texture;
import engine.window;

import utils.vector;

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
                path: "source/shaders/sprite.vert",
                type: GL_VERTEX_SHADER
            },
            {
                path: "source/shaders/sprite.frag",
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

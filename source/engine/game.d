module engine.game;

import bindbc.opengl;

import engine.resource_manager;
import engine.shader;
import engine.sprite_renderer;
import engine.window;

import utils.vector;

enum GameState
{
    active,
    menu,
    victory
}

struct Game
{
private:
    GameState       _state;
    Window          _window;
    ResourceManager _resourceManager;
    SpriteRenderer  _renderer;

public:
    this(Window window)
    {
        _window = window;
    }

    uint VBO, VAO;
    void initialize()
    {
        ShaderConfig[] shaderConfigs = [
            {
                source: vertexShaderSource,
                type:   GL_VERTEX_SHADER
            },
            {
                source: fragmentShaderSource,
                type:   GL_FRAGMENT_SHADER
            }
        ];

        auto spriteShader = _resourceManager.createShader("sprite", shaderConfigs);

        spriteShader.use();
        spriteShader.setInt("image", 0);
        spriteShader.setMatrix4("projection", window.projection);

        _renderer = SpriteRenderer(spriteShader);

        _resourceManager.createTexture("face", "assets/face.png");

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
            position: Vec2(200, 200),
            size:     Vec2(300, 400),
            rotate:   -45,
            color:    Vec3(0, 1, 0)
        };

        _renderer.drawSprite(spriteConfig);
    }

    @property
    Window window()
    {
        return _window;
    }
}

immutable string vertexShaderSource = q{
    #version 330 core
    layout (location = 0) in vec4 vertex; // <vec2 position, vec2 texCoords>

    out vec2 TexCoords;

    uniform mat4 model;
    uniform mat4 projection;

    void main()
    {
        TexCoords = vertex.zw;
        gl_Position = projection * model * vec4(vertex.xy, 0.0, 1.0);
    }
};

immutable string fragmentShaderSource = q{
    #version 330 core
    in vec2 TexCoords;
    out vec4 color;

    uniform sampler2D image;
    uniform vec3 spriteColor;

    void main()
    {    
        color = vec4(spriteColor, 1.0) * texture(image, vec2(TexCoords.x, 1 - TexCoords.y));
    }    
};

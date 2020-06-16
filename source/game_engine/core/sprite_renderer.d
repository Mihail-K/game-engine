module game_engine.core.sprite_renderer;

import bindbc.opengl;

import game_engine.core.shader;
import game_engine.core.texture;
import game_engine.utils.matrix;
import game_engine.utils.vector;

import gfm.math;

struct SpriteConfig
{
    Texture texture;
    Vec2    position = Vec2(0.0, 0.0);
    Vec2    size     = Vec2(10.0, 10.0);
    float   rotate   = 0.0;
    Vec3    color    = Vec3(1.0);
}

immutable float[] vertices = [
    // pos      // tex
    1.0f, 1.0f, 1.0f, 1.0f, // top right
    0.0f, 1.0f, 0.0f, 1.0f, // bottom right
    0.0f, 0.0f, 0.0f, 0.0f, // bottom left
    1.0f, 0.0f, 1.0f, 0.0f  // top left
];

immutable uint[] indices = [
    0, 1, 3, // 1st triangle
    1, 2, 3  // 2nd triangle
];

struct SpriteRenderer
{
private:
    Shader _shader;
    uint   _quadVAO;

public:
    @disable this();

    this(Shader shader)
    {
        _shader = shader;
        initRenderData();
    }

    void drawSprite(SpriteConfig config)
    {
        _shader.use();

        auto model = Mat4.identity;

        model = model.translation(Vec3(config.position, 0));

        if (config.rotate != 0)
        {
            auto angle = config.rotate.radians;

            model.translate(Vec3(0.5 * config.size.x, 0.5 * config.size.y, 0));
            model = model * Mat4.rotation(config.rotate.radians, Vec3(0, 0, 1));
            model.translate(Vec3(-0.5 * config.size.x, -0.5 * config.size.y, 0));
        }

        model.scale(Vec3(config.size, 1.0));

        _shader.setMatrix4("model", model);
        _shader.setVector3("spriteColor", config.color);

        glActiveTexture(GL_TEXTURE0);
        config.texture.bind();

        glBindVertexArray(_quadVAO);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, cast(void*) 0);
        glBindVertexArray(0);
    }

private:
    void initRenderData()
    {
        uint VBO, EBO;

        glGenVertexArrays(1, &_quadVAO);
        glGenBuffers(1, &VBO);
        glGenBuffers(1, &EBO);

        glBindVertexArray(_quadVAO);

        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices.ptr, GL_STATIC_DRAW);

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * uint.sizeof, indices.ptr, GL_STATIC_DRAW);

        glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * float.sizeof, cast(void*) 0);
        glEnableVertexAttribArray(0);

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);
    }
}

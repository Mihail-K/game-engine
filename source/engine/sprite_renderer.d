module engine.sprite_renderer;

import bindbc.opengl;

import engine.shader;
import engine.texture;

import gfm.math;

import utils.matrix;
import utils.vector;

struct SpriteConfig
{
    Texture texture;
    Vec2    position;
    Vec2    size   = Vec2(10.0, 10.0);
    float   rotate = 0.0;
    Vec3    color  = Vec3(1.0);
}

immutable float[] vertices = [
    // pos      // tex
    0.0f, 1.0f, 0.0f, 1.0f,
    1.0f, 0.0f, 1.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 0.0f, 

    0.0f, 1.0f, 0.0f, 1.0f,
    1.0f, 1.0f, 1.0f, 1.0f,
    1.0f, 0.0f, 1.0f, 0.0f
];

struct SpriteRenderer
{
private:
    Shader _shader;
    uint   _quadVAO;

public:
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

        model.translate(Vec3(0.5 * config.size.x, 0.5 * config.size.y, 0));
        model = model * Mat4.rotation(config.rotate.radians, Vec3(0, 0, 1));
        model.translate(Vec3(-0.5 * config.size.x, -0.5 * config.size.y, 0));

        model.scale(Vec3(config.size, 1.0));

        _shader.setMatrix4("model", model);
        _shader.setVector3("spriteColor", config.color);

        glActiveTexture(GL_TEXTURE0);
        config.texture.bind();

        glBindVertexArray(_quadVAO);
        glDrawArrays(GL_TRIANGLES, 0, 6);
        glBindVertexArray(0);
    }

private:
    void initRenderData()
    {
        uint VBO;

        glGenVertexArrays(1, &_quadVAO);
        glGenBuffers(1, &VBO);
        glBindVertexArray(_quadVAO);

        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices.ptr, GL_STATIC_DRAW);

        glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * float.sizeof, cast(void*) 0);
        glEnableVertexAttribArray(0);

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);
    }
}

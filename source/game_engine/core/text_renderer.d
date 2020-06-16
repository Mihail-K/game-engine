module game_engine.core.text_renderer;

import bindbc.opengl;

import game_engine.core.font;
import game_engine.core.shader;
import game_engine.utils.vector;

struct TextConfig
{
    Font  font;
    Vec2  position = Vec2(0);
    float scale    = 1;
    Vec3  color    = Vec3(1);
}

struct TextRenderer
{
private:
    alias TextVertexBuffer = float[4][6];

    Shader _shader;
    uint   _textVAO;
    uint   _textVBO;

public:
    @disable this();

    this(Shader shader)
    {
        _shader = shader;
        initRenderData();
    }

    void drawText(string text, TextConfig config)
    {
        _shader.use();
        _shader.setVector3("textColor", config.color);

        glActiveTexture(GL_TEXTURE0);
        glBindVertexArray(_textVAO);

        foreach (ch; text)
        {
            auto fontChar = config.font.getChar(ch);

            float xPos = config.position.x + fontChar.bearing.x * config.scale;
            float yPos = config.position.y - (fontChar.size.y - fontChar.bearing.y) * config.scale;

            float width  = fontChar.size.x * config.scale;
            float height = fontChar.size.y * config.scale;

            TextVertexBuffer vertices = [
                [xPos,         yPos + height,   0.0f, 0.0f],            
                [xPos,         yPos,            0.0f, 1.0f],
                [xPos + width, yPos,            1.0f, 1.0f],

                [xPos,         yPos + height,   0.0f, 0.0f],
                [xPos + width, yPos,            1.0f, 1.0f],
                [xPos + width, yPos + height,   1.0f, 0.0f]       
            ];

            glBindTexture(GL_TEXTURE_2D, fontChar.textureID);

            glBindBuffer(GL_ARRAY_BUFFER, _textVBO);
            glBufferSubData(GL_ARRAY_BUFFER, 0, vertices.sizeof, vertices.ptr);
            glBindBuffer(GL_ARRAY_BUFFER, 0);

            glDrawArrays(GL_TRIANGLES, 0, vertices.length);
            config.position.x += (fontChar.advance >> 6) * config.scale;
        }

        glBindTexture(GL_TEXTURE_2D, 0);
        glBindVertexArray(0);
    }

private:
    void initRenderData()
    {
        glGenVertexArrays(1, &_textVAO);
        glGenBuffers(1, &_textVBO);

        glBindVertexArray(_textVAO);
        glBindBuffer(GL_ARRAY_BUFFER, _textVBO);
        glBufferData(GL_ARRAY_BUFFER, TextVertexBuffer.sizeof, null, GL_DYNAMIC_DRAW);

        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, float.sizeof * 4, cast(void*) 0);

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);
    }
}

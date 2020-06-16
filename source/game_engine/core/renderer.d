module game_engine.core.renderer;

import game_engine.core.sprite_renderer;
import game_engine.core.text_renderer;

struct Renderer
{
private:
    SpriteRenderer _spriteRenderer;
    TextRenderer   _textRenderer;

public:
    void drawSprite(SpriteConfig config)
    {
        _spriteRenderer.drawSprite(config);
    }

    void drawText(string text, TextConfig config)
    {
        _textRenderer.drawText(text, config);
    }
}

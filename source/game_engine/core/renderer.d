module game_engine.core.renderer;

import game_engine.core.sprite_renderer;

struct Renderer
{
private:
    SpriteRenderer _spriteRenderer;

public:
    void drawSprite(SpriteConfig config)
    {
        _spriteRenderer.drawSprite(config);
    }
}

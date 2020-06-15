module game_engine.core.game_container;

import game_engine.core.resource_manager;
import game_engine.core.sprite_renderer;

struct GameContainer
{
private:
    ResourceManager _resourceManager;
    SpriteRenderer  _spriteRenderer;

public:
    @property
    ResourceManager resourceManager()
    {
        return _resourceManager;
    }

    @property
    SpriteRenderer spriteRenderer()
    {
        return _spriteRenderer;
    }
}

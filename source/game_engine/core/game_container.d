module game_engine.core.game_container;

import game_engine.core.resource_manager;
import game_engine.core.renderer;
import game_engine.core.window;
import game_engine.ecs.entity_manager;

struct GameContainer
{
private:
    ResourceManager _resourceManager;
    EntityManager   _entityManager;
    Renderer        _renderer;
    Window          _window;

public:
    @property
    ResourceManager resourceManager()
    {
        return _resourceManager;
    }

    @property
    EntityManager entityManager()
    {
        return _entityManager;
    }

    @property
    Renderer renderer()
    {
        return _renderer;
    }

    @property
    Window window()
    {
        return _window;
    }
}

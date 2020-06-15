module game_engine.core.game_container;

import game_engine.core.resource_manager;
import game_engine.core.renderer;
import game_engine.core.window;

struct GameContainer
{
private:
    ResourceManager _resourceManager;
    Renderer        _renderer;
    Window          _window;

public:
    @property
    ResourceManager resourceManager()
    {
        return _resourceManager;
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

module game_engine.ecs.system_manager;

import game_engine.core.game_container;
import game_engine.ecs.system;

import std.algorithm;

class SystemManager
{
private:
    System[] _systems;

public:
    void addSystem(System system)
    {
        _systems ~= system;
    }

    bool removeSystem(System system)
    {
        auto index = _systems.countUntil(system);

        if (index != -1)
        {
            _systems.remove(index);

            return true;
        }

        return false;
    }

    void setup(GameContainer container)
    {
        foreach (system; _systems)
        {
            system.setup(container);
        }
    }

    void teardown(GameContainer container)
    {
        import std.range : retro;

        foreach (system; _systems.retro)
        {
            system.teardown(container);
        }
    }

    void update(GameContainer container, float delta)
    {
        foreach (system; _systems)
        {
            system.update(container, delta);
        }
    }
}

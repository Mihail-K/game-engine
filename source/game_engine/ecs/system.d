module game_engine.ecs.system;

import game_engine.core.game_engine;
import game_engine.core.window;
import game_engine.ecs.entity_manager;

abstract class System
{
private:
    GameEngine    _gameEngine;
    EntityManager _entityManager;

public:
    this(GameEngine gameEngine, EntityManager entityManager)
    {
        _gameEngine    = gameEngine;
        _entityManager = entityManager;
    }

    void setup()
    {
        // Nothing.
    }

    void teardown()
    {
        // Nothing.
    }

    abstract void update(float delta);

protected:
    @property
    GameEngine gameEngine()
    {
        return _gameEngine;
    }

    @property
    Window window()
    {
        return _gameEngine.window;
    }

    @property
    EntityManager entityManager()
    {
        return _entityManager;
    }
}

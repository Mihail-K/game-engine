module game_engine.ecs.system;

import game_engine.core.game_container;
import game_engine.core.window;
import game_engine.ecs.entity_manager;

abstract class System
{
private:
    GameContainer _gameContainer;
    EntityManager _entityManager;

public:
    this(GameContainer gameContainer, EntityManager entityManager)
    {
        _gameContainer = gameContainer;
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
    GameContainer gameContainer()
    {
        return _gameContainer;
    }

    @property
    Window window()
    {
        return _gameContainer.window;
    }

    @property
    EntityManager entityManager()
    {
        return _entityManager;
    }
}

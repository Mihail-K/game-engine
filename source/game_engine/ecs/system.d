module game_engine.ecs.system;

import game_engine.core.game_container;
import game_engine.core.window;
import game_engine.ecs.entity_manager;

abstract class System
{
private:
    GameContainer _gameContainer;

public:
    this(GameContainer gameContainer)
    {
        _gameContainer = gameContainer;
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
    EntityManager entityManager()
    {
        return _gameContainer.entityManager;
    }
}

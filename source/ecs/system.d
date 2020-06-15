module ecs.system;

import ecs.entity_manager;

import engine.game;
import engine.window;

abstract class System
{
private:
    Game _game;
    EntityManager _entityManager;

public:
    this(Game game, EntityManager entityManager)
    {
        _game          = game;
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
    Game game()
    {
        return _game;
    }

    @property
    Window window()
    {
        return _game.window;
    }

    @property
    EntityManager entityManager()
    {
        return _entityManager;
    }
}

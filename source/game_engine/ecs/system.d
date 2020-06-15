module game_engine.ecs.system;

import game_engine.core.game_container;

abstract class System
{
    void setup(GameContainer)
    {
        // Nothing.
    }

    void teardown(GameContainer)
    {
        // Nothing.
    }

    abstract void update(GameContainer, float delta);
}

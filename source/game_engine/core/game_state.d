module game_engine.core.game_state;

import game_engine.core.game_container;

alias GameStateID = ulong;

immutable GameStateID defaultGameStateID = 0UL;

abstract class GameState
{
    @property
    abstract GameStateID gameStateID() const;

    void setup(GameContainer)
    {
        // Nothing.
    }

    void teardown(GameContainer)
    {
        // Nothing.
    }

    void processInput(GameContainer, float delta)
    {
        // Nothing.
    }

    void update(GameContainer, float delta)
    {
        // Nothing
    }

    void render(GameContainer)
    {
        // Nothing.
    }
}

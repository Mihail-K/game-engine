module engine.game;

import engine.window;

enum GameState
{
    active,
    menu,
    victory
}

struct Game
{
private:
    GameState    _state;
    WindowConfig _windowConfig;
    Window       _window;

public:
    this(WindowConfig windowConfig)
    {
        _windowConfig = windowConfig;
    }

    void initialize()
    {

    }

    void processInput(float delta)
    {

    }

    void update(float delta)
    {

    }

    void render()
    {

    }
}

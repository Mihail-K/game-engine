module ecs.entity;

import ecs.component;

import std.algorithm;

alias EntityID = ulong;

package struct Entity
{
private:
    Component[][ComponentID] _components;

public:
    void addComponent(Component component)
    {
        if (auto ptr = component.componentID in _components)
        {
            (*ptr) ~= component;
        }
        else
        {
            _components[component.componentID] = [component];
        }
    }

    @property
    auto components()
    {
        return _components.values.joiner;
    }

    bool hasComponents(ComponentID componentID)
    {
        return !!(componentID in _components);
    }

    Component[] getComponents(ComponentID componentID)
    {
        if (auto ptr = componentID in _components)
        {
            return *ptr;
        }

        return null;
    }

    bool removeComponent(Component component)
    {
        if (auto ptr = component.componentID in _components)
        {
            auto index = (*ptr).countUntil(component);

            if (index != -1)
            {
                (*ptr).remove(index);

                if (ptr.length == 0)
                {
                    _components.remove(component.componentID);
                }

                return true;
            }
        }

        return false;
    }

    bool removeComponents(ComponentID componentID)
    {
        return _components.remove(componentID);
    }
}

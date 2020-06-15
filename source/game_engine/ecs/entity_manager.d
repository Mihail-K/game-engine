module game_engine.ecs.entity_manager;

import game_engine.ecs.component;
import game_engine.ecs.entity;
import game_engine.utils.set;

class EntityManager
{
private:
    Entity[EntityID]            _entities;
    Set!(EntityID)[ComponentID] _index;
    EntityID                    _entitySeries;

public:
    EntityID createEntity(Component[] components...)
    {
        EntityID entityID   = nextEntityID();
        _entities[entityID] = Entity.init;

        addComponents(entityID, components);

        return entityID;
    }

    EntityID[] getEntities(ComponentID componentID)
    {
        if (auto ptr = componentID in _index)
        {
            return (*ptr)[];
        }

        return null;
    }

    bool destroyEntity(EntityID entityID)
    {
        if (auto entity = entityID in _entities)
        {
            foreach (component; entity.components)
            {
                entity.removeComponent(component);
                removeFromIndex(component.componentID, entityID);
            }

            _entities.remove(entityID);

            return true;
        }

        return false;
    }

    bool addComponents(EntityID entityID, Component[] components...)
    {
        if (auto entity = entityID in _entities)
        {
            foreach (component; components)
            {
                entity.addComponent(component);
                addToIndex(component.componentID, entityID);
            }

            return true;
        }

        return false;
    }

    Component[] getComponents(EntityID entityID, ComponentID componentID)
    {
        if (auto entity = entityID in _entities)
        {
            return entity.getComponents(componentID);
        }

        return null;
    }

    bool removeComponents(EntityID entityID, Component[] components...)
    {
        if (auto entity = entityID in _entities)
        {
            foreach (component; components)
            {
                entity.removeComponent(component);

                if (!entity.hasComponents(component.componentID))
                {
                    removeFromIndex(component.componentID, entityID);
                }
            }

            return true;
        }

        return false;
    }

    bool removeComponents(EntityID entityID, ComponentID componentID)
    {
        if (auto entity = entityID in _entities)
        {
            entity.removeComponents(componentID);
            removeFromIndex(componentID, entityID);

            return true;
        }

        return false;
    }

private:
    EntityID nextEntityID()
    {
        return ++_entitySeries;
    }

    void addToIndex(ComponentID componentID, EntityID entityID)
    {
        if (auto ptr = componentID in _index)
        {
            (*ptr) ~= entityID;
        }
        else
        {
            _index[componentID] = Set!(EntityID)(entityID);
        }
    }

    void removeFromIndex(ComponentID componentID, EntityID entityID)
    {
        if (auto ptr = componentID in _index)
        {
            ptr.remove(entityID);

            if (ptr.length == 0)
            {
                _index.remove(componentID);
            }
        }
    }
}

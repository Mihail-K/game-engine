module ecs.entity_manager;

import ecs.component;
import ecs.entity;

import utils.set;

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
                _index[component.componentID].remove(entityID);
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
                _index[component.componentID] ~= entityID;
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
                    _index[component.componentID].remove(entityID);
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
            _index[componentID].remove(entityID);

            return true;
        }

        return false;
    }

private:
    EntityID nextEntityID()
    {
        return ++_entitySeries;
    }
}

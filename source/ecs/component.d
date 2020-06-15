module ecs.component;

alias ComponentID = string;

interface Component
{
    @property
    abstract ComponentID componentID() const;
}

module utils.set;

struct Set(T)
{
private:
    alias ElementType = void[0];

    ElementType[T] _elements;

public:
    this(T[] elements...)
    {
        add(elements);
    }

    this(const ref Set other)
    {
        add(other[]);
    }

    void add(T element)
    {
        _elements[element] = ElementType.init;
    }

    void add(T[] elements...)
    {
        foreach (element; elements)
        {
            add(element);
        }
    }

    bool contains(T element) const
    {
        return !!(element in _elements);
    }

    @property
    bool empty() const
    {
        return length == 0;
    }

    @property
    T front() const
    {
        return _elements.keys[0];
    }

    @property
    size_t length() const
    {
        return _elements.length;
    }

    Set opBinary(string op : "~")(T[] elements...)
    {
        Set result = Set(this);

        result.add(elements);

        return result;
    }

    T[] opIndex() const
    {
        return _elements.keys;
    }

    Set opOpAssign(string op : "~")(T[] elements...)
    {
        add(elements);

        return this;
    }

    void popFront()
    {
        remove(front);
    }

    bool remove(T element)
    {
        return _elements.remove(element);
    }

    void remove(T[] elements...)
    {
        foreach (element; elements)
        {
            remove(element);
        }
    }

    Set save()
    {
        return Set(this);
    }

    string toString() const
    {
        import std.conv : to;

        return this[].to!(string);
    }
}

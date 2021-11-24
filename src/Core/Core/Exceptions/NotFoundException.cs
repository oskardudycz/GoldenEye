using System;

namespace GoldenEye.Exceptions;

public class NotFoundException: Exception
{
    private NotFoundException(Type type, object id): base($"{type.Name} with id: {id} was not found.")
    {
        Type = type;
        Id = id;
    }

    public Type Type { get; }
    public object Id { get; }

    public static NotFoundException For(Type type, object id) => new NotFoundException(type, id);

    public static NotFoundException For<T>(object id) => For(typeof(T), id);
}
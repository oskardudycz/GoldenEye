using System;

namespace GoldenEye.Backend.Core.Exceptions
{
    public class NotFoundException: Exception
    {
        public Type Type { get; }
        public object Id { get; }

        private NotFoundException(Type type, object id): base($"{type.Name} with id: {id} was not found.")
        {
            Type = type;
            Id = id;
        }

        public static NotFoundException For(Type type, object id) => new NotFoundException(type, id);

        public static NotFoundException For<T>(object id) => For(typeof(T), id);
    }
}

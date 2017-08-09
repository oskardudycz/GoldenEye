using System;

namespace GoldenEye.Shared.Core.Objects.General
{
    public interface IHasObjectId
    {
        object Id { get; }
    }

    public interface IHasId<T> : IHasObjectId
    {
        new T Id { get; }
    }

    public interface IHasGuidId : IHasId<Guid>
    {
    }

    public interface IHasId : IHasId<int>
    {
    }
}
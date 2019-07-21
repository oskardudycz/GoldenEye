using System;

namespace GoldenEye.Shared.Core.Objects.General
{
    public interface IHasId
    {
        object Id { get; }
    }

    public interface IHasId<T>: IHasId
    {
        new T Id { get; }
    }

    public interface IHasGuidId: IHasId<Guid>
    {
    }

    public interface IHasStringId: IHasId<string>
    {
    }

    public interface IHasIntId: IHasId<int>
    {
    }
}

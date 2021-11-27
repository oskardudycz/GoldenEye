using System;

namespace GoldenEye.Objects.General;

public interface IHaveId
{
    object Id { get; }
}

public interface IHaveId<out T>: IHaveId
    where T: notnull
{
    new T Id { get; }

    object IHaveId.Id => Id;
}

public interface IHaveGuidId: IHaveId<Guid>
{
}

public interface IHaveStringId: IHaveId<string>
{
}

public interface IHaveIntId: IHaveId<int>
{
}

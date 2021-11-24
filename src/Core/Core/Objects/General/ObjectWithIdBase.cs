using System;

namespace GoldenEye.Objects.General;

public abstract class ObjectWithIdBase: IHaveId
{
    object IHaveId.Id { get; }
}

public abstract class ObjectWithIdBase<T>: IHaveId<T>
{
    public T Id { get; set; }

    object IHaveId.Id
    {
        get { return Id; }
    }
}

public abstract class ObjectWithGuidIdBase: ObjectWithIdBase<Guid>, IHaveGuidId
{
}

public abstract class ObjectWithIntIdBase: ObjectWithIdBase<int>, IHaveId
{
}
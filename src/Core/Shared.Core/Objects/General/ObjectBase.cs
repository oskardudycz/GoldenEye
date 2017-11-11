using System;

namespace GoldenEye.Shared.Core.Objects.General
{
    public class ObjectBase : IBusinessObject
    {
    }

    public abstract class ObjectWithIdBase : ObjectBase, IHasId
    {
        object IHasId.Id { get; }
    }

    public abstract class ObjectWithIdBase<T> : IHasId<T>
    {
        public T Id { get; set; }

        object IHasId.Id
        {
            get { return Id; }
        }
    }

    public abstract class ObjectWithGuidIdBase : ObjectWithIdBase<Guid>, IHasGuidId
    {
    }

    public abstract class ObjectWithIntIdBase :ObjectWithIdBase<int>, IHasId
    {
    }
}

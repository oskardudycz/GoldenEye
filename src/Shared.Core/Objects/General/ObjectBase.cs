using System;

namespace GoldenEye.Shared.Core.Objects.General
{
    public class ObjectBase : IBusinessObject
    {
    }

    public abstract class ObjectWithIdBase : ObjectBase, IHasObjectId
    {
        object IHasObjectId.Id { get; set; }
    }

    public abstract class ObjectWithIdBase<T> : IHasId<T>
    {
        public T Id { get; set; }

        object IHasObjectId.Id
        {
            get { return Id; }
            set { Id = (T)value; }
        }
    }

    public abstract class ObjectWithGuidIdBase : ObjectWithIdBase<Guid>, IHasGuidId
    {
    }

    public abstract class ObjectWithIntIdBase :ObjectWithIdBase<int>, IHasId
    {
    }
}

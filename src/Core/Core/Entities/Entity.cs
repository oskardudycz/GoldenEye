using System;
using GoldenEye.Objects.General;

namespace GoldenEye.Entities
{
    public class Entity<TKey>: IEntity<TKey>
    {
        public virtual TKey Id { get; set; }

        object IHaveId.Id
        {
            get { return Id; }
        }
    }

    public class Entity: Entity<Guid>
    {
    }
}

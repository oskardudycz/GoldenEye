using GoldenEye.Shared.Core;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.Entity
{
    public class EntityBase : IEntity
    {
        public virtual int Id { get; set; }

        object IHasObjectId.Id
        {
            get { return Id; }
        }
    }
}
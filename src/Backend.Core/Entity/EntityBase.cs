using GoldenEye.Shared.Core;

namespace GoldenEye.Backend.Core.Entity
{
    public class EntityBase : IEntity
    {
        public virtual int Id { get; set; }

        object IHasObjectId.Id
        {
            get { return Id; }
            set { Id = (int) value; }
        }
    }
}
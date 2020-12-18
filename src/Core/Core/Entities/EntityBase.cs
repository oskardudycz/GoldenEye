using GoldenEye.Core.Objects.General;

namespace GoldenEye.Core.Entities
{
    public class EntityBase: IEntity
    {
        public virtual int Id { get; set; }

        object IHaveId.Id
        {
            get { return Id; }
        }
    }
}

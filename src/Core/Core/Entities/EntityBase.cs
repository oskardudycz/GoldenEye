using GoldenEye.Objects.General;

namespace GoldenEye.Entities
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

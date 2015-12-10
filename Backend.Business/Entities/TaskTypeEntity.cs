using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.Backend.Business.Entities
{
    public class TaskTypeEntity : EntityBase
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }
}
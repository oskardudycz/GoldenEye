using Backend.Core.Entity;

namespace Backend.Business.Entities
{
    public class TaskTypeEntity : EntityBase
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }
}
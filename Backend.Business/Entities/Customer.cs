using Backend.Core.Entity;

namespace Backend.Business.Entities
{
    public class Customer : EntityBase
    {
        public override int Id { get; set; }
        public string Name { get; set; }
    }
}
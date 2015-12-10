using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.Backend.Business.Entities
{
    public class Customer : EntityBase
    {
        public override int Id { get; set; }
        public string Name { get; set; }
    }
}
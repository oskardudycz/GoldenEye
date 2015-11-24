using Backend.Core.Entity;

namespace Backend.Business.Entities
{
    public class ModelerUser : EntityBase
    {
        public override int Id { get; set; }
        public string Name { get; set; }
        public string Surname { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
    }
}
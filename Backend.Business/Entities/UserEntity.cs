using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.Backend.Business.Entities
{
    public class UserEntity : EntityBase
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
    }
}
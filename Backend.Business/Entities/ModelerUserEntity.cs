using Backend.Core.Entity;

namespace Backend.Business.Entities
{
    public class ModelerUserEntity : EntityBase
    {
        public string Login {get; set; }
        public string Name { get; set; }
        public string Surname { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public bool IsActive { get; set; }
        public bool IsValid { get; set; }
        public bool IsDeleted { get; set; }

        public bool CanLogin
        {
            get { return IsActive && IsValid && !IsDeleted; }
        }
    }
}
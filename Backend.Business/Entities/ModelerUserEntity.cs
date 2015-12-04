using System;
using Backend.Core.Entity;

namespace Backend.Business.Entities
{
    public class ModelerUserEntity : EntityBase
    {
        public int? IdArch { get; set; }
        public string UserName {get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public bool IsActive { get; set; }
        public bool IsValid { get; set; }
        public bool IsDeleted { get; set; }
        public DateTime ModificationDate { get; set; }

        public bool CanLogin
        {
            get { return IsActive && IsValid && !IsDeleted && !IdArch.HasValue; }
        }
    }
}
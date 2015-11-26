using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Shared.Core.DTOs;

namespace Shared.Business.DTOs
{
    public class ModelerUserDTO: DTOBase
    {
        public string Login { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
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
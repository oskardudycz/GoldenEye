using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Shared.Business.DTOs
{
    public class UserDTO
    {
        public int Id { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
    }
}
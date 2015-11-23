using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations.Schema;
using Backend.Core.Entity;

namespace Backend.Business.Entities
{
    public class UserEntity : EntityBase
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public int ClientRefId { get; set; }
        public virtual ClientEntity Client { get; set; }
    }
}
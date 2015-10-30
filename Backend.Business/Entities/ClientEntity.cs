using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Backend.Business.Entities
{
    public class ClientEntity
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public virtual ICollection<TaskTypeEntity> TaskTypes { get; set; }
        public virtual ICollection<UserEntity> Users { get; set; }
    }
}
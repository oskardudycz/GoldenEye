using System.Collections.Generic;
using Backend.Core.Entity;

namespace Backend.Business.Entities
{
    public class ClientEntity : EntityBase
    {
        public string Name { get; set; }
        public virtual ICollection<TaskTypeEntity> TaskTypes { get; set; }
        public virtual ICollection<UserEntity> Users { get; set; }
    }
}
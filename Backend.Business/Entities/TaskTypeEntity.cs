using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Backend.Core.Entity;

namespace Backend.Business.Entities
{
    public class TaskTypeEntity : IEntity
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public virtual ICollection<ClientEntity> Clients { get; set; }
    }
}
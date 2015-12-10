using System.Collections.Generic;
using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.Backend.Business.Entities
{
    public class ClientEntity : EntityBase
    {
        public string Name { get; set; }
        public virtual ICollection<UserEntity> Users { get; set; }
    }
}
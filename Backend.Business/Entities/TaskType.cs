using System.ComponentModel.DataAnnotations.Schema;
using Backend.Core.Entity;

namespace Backend.Business.Entities
{
    public class TaskType : EntityBase
    {
        public override int Id { get; set; }
        public string Name { get; set; }
    }
}
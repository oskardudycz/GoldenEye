using System.ComponentModel.DataAnnotations.Schema;
using Backend.Core.Entity;

namespace Backend.Business.Entities
{
    public class Customer : EntityBase
    {
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public override int Id { get; set; }
        public string Name { get; set; }
    }
}
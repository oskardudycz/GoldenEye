using GoldenEye.Shared.Core.DTOs;

namespace GoldenEye.Shared.Business.DTOs
{
    public class TaskTypeDTO : DTOBase
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public bool IsDeleted { get; set; }
    }
}
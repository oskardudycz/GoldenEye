using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Business.Repository;
using GoldenEye.Backend.Core.Service;
using GoldenEye.Shared.Business.DTOs;

namespace GoldenEye.Backend.Business.Services
{
    public class TaskTypeRestService : ReadonlyRestServiceBase<TaskTypeDTO, TaskTypeEntity>, ITaskTypeRestService
    {
        public TaskTypeRestService(ITaskTypeRepository repository)
            : base(repository)
        {
        }
    }
}
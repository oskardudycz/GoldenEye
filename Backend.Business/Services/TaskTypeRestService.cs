using Shared.Business.DTOs;
using Backend.Business.Entities;
using Backend.Core.Service;
using Backend.Business.Repository;

namespace Backend.Business.Services
{
    public class TaskTypeRestService : ReadonlyRestServiceBase<TaskTypeDTO, TaskType>, ITaskTypeRestService
    {
        public TaskTypeRestService(ITaskTypeRepository repository)
            : base(repository)
        {
        }
    }
}
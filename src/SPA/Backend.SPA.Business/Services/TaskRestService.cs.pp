using FluentValidation;
using GoldenEye.Backend.Core.Service;
using $rootnamespace$.Entities;
using $rootnamespace$.Repository;

namespace $rootnamespace$.Services
{
    public class TaskRestService: RestServiceBase<TaskDTO, TaskEntity>, ITaskRestService
    {
        public TaskRestService(ITaskRepository repository)
            : base(repository)
        {
        }

        protected override AbstractValidator<TaskDTO> GetValidator()
        {
            return new TaskValidator();
        }
    }
}

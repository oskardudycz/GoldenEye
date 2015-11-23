using Backend.Business.Context;
using Backend.Core.Service;
using Shared.Business.DTOs;
using Shared.Business.Validators;
using Backend.Business.Repository;
using FluentValidation;

namespace Backend.Business.Services
{
    public class TaskRestService: RestServiceBase<TaskDTO, Task>, ITaskRestService
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

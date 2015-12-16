using FluentValidation;
using GoldenEye.Backend.Core.Service;
using GoldenEye.SPA.Business.Sample.Entities;
using GoldenEye.SPA.Business.Sample.Repository;
using GoldenEye.SPA.Shared.Sample.DTOs;
using GoldenEye.SPA.Shared.Sample.Services;
using GoldenEye.SPA.Shared.Sample.Validators;

namespace GoldenEye.SPA.Business.Sample.Services
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

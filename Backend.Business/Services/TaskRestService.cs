using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Backend.Core.Service;
using Shared.Business.DTOs;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using System.Threading.Tasks;
using Shared.Business.Validators;
using Backend.Business.Entities;
using Backend.Business.Repository;
using FluentValidation;

namespace Backend.Business.Services
{
    public class TaskRestService: RestServiceBase<TaskDTO, TaskEntity>, ITaskRestService
    {
        private readonly ITaskRepository _repository;
        public TaskRestService(ITaskRepository repository)
            : base(repository)
        {
            _repository = repository;
        }

        protected override AbstractValidator<TaskDTO> GetValidator()
        {
            return new TaskValidator();
        }
    }
}

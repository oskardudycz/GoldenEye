using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Shared.Business.DTOs;
using Backend.Business.Entities;
using Backend.Core.Service;
using Backend.Business.Repository;

namespace Backend.Business.Services
{
    public class TaskTypeRestService : RestServiceBase<TaskTypeDTO, TaskTypeEntity>, ITaskTypeRestService
    {
        private readonly ITaskTypeRepository _repository;
        public TaskTypeRestService(ITaskTypeRepository repository)
            : base(repository)
        {
            _repository = repository;
        }
    }
}
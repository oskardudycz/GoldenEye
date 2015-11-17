using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Backend.Core.Service;
using Shared.Business.DTOs;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using System.Threading.Tasks;
using Shared.Business.Contracts;
using Shared.Business.Validators;

namespace Backend.Business.Services
{
    public class TaskRestService: RestServiceBase<TaskDTO, TaskContract>, ITaskRestService
    {
        private readonly ITaskService _service;

        public TaskRestService(ITaskService service)
            : base(service)
        {
            _service = service;
        }
        public override void Dispose()
        {
          _service.Dispose();
        }
    }
}

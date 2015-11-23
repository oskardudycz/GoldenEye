using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Shared.Business.DTOs;
using Backend.Business.Services;

namespace Frontend.Web.Controllers
{
    public class TaskTypeController : RestControllerBase<ITaskRestService, TaskTypeDTO>
    {
        ITaskRestService _service;
        public TaskTypeController()
        {
        }

        public TaskTypeController(ITaskRestService service)
            : base(service)
        {
            _service = service;
        }
    }
}

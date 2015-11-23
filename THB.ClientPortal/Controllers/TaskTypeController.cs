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
    public class TaskTypeController : RestControllerBase<ITaskTypeRestService, TaskTypeDTO>
    {
        public TaskTypeController()
        {
        }

        public TaskTypeController(ITaskTypeRestService service)
            : base(service)
        {
        }
    }
}

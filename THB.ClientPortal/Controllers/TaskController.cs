using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Frontend.Web.Models;
using Backend.Business.Services;
using Shared.Business.DTOs;

namespace Frontend.Web.Controllers
{
    public class TaskController : RestControllerBase<ITaskRestService, TaskDTO>
    {
        ITaskRestService _service;
        public TaskController()
        {
        }

        public TaskController(ITaskRestService service)
            : base(service)
        {
            _service = service;
        }
    }
}

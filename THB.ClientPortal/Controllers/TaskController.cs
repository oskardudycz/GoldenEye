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
        private readonly ITaskService _service;
        /*
        static List<TaskDTO> tasks = new List<TaskDTO> 
        {
            new TaskDTO { Id = 1, TaskName = "Batman" },
            new TaskDTO { Id = 2, TaskName = "Natasha" },
            new TaskDTO { Id = 3, TaskName = "Daredevil" } 
        };
        */

        public TaskController()
        {
        }

        public TaskController(ITaskRestService service)

        {
            Service = service;

        }
    }
}

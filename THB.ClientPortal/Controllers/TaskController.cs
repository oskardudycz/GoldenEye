using Backend.Business.Services;
using Frontend.Web.Core.Controllers;
using Shared.Business.DTOs;

namespace Frontend.Web.Controllers
{
    public class TaskController : RestControllerBase<ITaskRestService, TaskDTO>
    {
        public TaskController()
        {
        }

        public TaskController(ITaskRestService service)
            : base(service)
        {
        }
    }
}

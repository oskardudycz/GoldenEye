using Shared.Business.DTOs;
using Backend.Business.Services;
using Frontend.Web.Core.Controllers;

namespace Frontend.Web.Controllers
{
    public class TaskTypeController : ReadonlyRestControllerBase<ITaskTypeRestService, TaskTypeDTO>
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

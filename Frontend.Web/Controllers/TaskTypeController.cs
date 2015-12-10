using System.Web.Http;
using GoldenEye.Backend.Business.Services;
using GoldenEye.Frontend.Core.Web.Controllers;
using GoldenEye.Shared.Business.DTOs;

namespace GoldenEye.Frontend.Web.Controllers
{
    [Authorize]
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

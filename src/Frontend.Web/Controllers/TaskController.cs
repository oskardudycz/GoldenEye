using System.Web.Http;
using GoldenEye.Backend.Business.Services;
using GoldenEye.Frontend.Core.Web.Controllers;
using GoldenEye.Shared.Business.DTOs;

namespace GoldenEye.Frontend.Web.Controllers
{
    [Authorize]
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

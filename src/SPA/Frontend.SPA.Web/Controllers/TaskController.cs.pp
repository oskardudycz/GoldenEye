using System.Web.Http;
using $rootnamespace$;
using GoldenEye.Frontend.Core.Web.Controllers;
using Shared.Business.DTOs;
using Shared.Business.Services;

namespace $rootnamespace$.Controllers
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

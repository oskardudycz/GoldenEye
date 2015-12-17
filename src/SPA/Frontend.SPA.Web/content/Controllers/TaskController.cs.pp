using System.Web.Http;
using $rootnamespace$;
using GoldenEye.Frontend.Core.Web.Controllers;

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

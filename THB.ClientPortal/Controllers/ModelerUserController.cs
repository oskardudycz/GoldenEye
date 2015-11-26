using System.Web.Http;
using Shared.Business.DTOs;
using Backend.Business.Services;
using Frontend.Web.Core.Controllers;

namespace Frontend.Web.Controllers
{
    [Authorize]
    public class ModelerUserController : ReadonlyRestControllerBase<IModelerUserRestService, UserDTO>
    {
        public ModelerUserController()
        {
        }

        public ModelerUserController(IModelerUserRestService service)
            : base(service)
        {
        }
    }
}

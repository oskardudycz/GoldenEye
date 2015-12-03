using System.Web.Http;
using Shared.Business.DTOs;
using Backend.Business.Services;
using Frontend.Web.Core.Controllers;

namespace Frontend.Web.Controllers
{
    [Authorize]
    public class UserController : ReadonlyRestControllerBase<IModelerUserRestService, UserDTO>
    {
        public UserController()
        {
        }

        public UserController(IModelerUserRestService service)
            : base(service)
        {
        }
    }
}

using System.Linq;
using System.Web.Http;
using System.Web.Http.OData;
using GoldenEye.Backend.Security.Service;
using GoldenEye.Frontend.Core.Web.Controllers;
using GoldenEye.Shared.Core.DTOs;

namespace GoldenEye.Frontend.Security.Web.Controllers
{
    [Authorize]
    public class UserControllerBase : ReadonlyRestControllerBase<IUserRestService, UserDTO>
    {
        public UserControllerBase()
        {
        }

        public UserControllerBase(IUserRestService service)
            : base(service)
        {
        }

        [EnableQuery]
        public override IQueryable<UserDTO> Get()
        {
            return Service.Get();
        }
    }
}
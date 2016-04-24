using System.Linq;
using System.Web.Http;
using System.Web.Http.OData;
using GoldenEye.Backend.Security.Service;
using GoldenEye.Frontend.Core.Web.Controllers;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Frontend.Security.Web.Controllers
{
    [Authorize]
    public abstract class UserControllerBase : ReadonlyRestControllerBase<IUserRestService, UserDTO>
    {
        protected UserControllerBase()
        {
            
        }

        protected UserControllerBase(IUserRestService service)
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
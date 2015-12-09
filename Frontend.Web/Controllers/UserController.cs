using System.Web.Http;
using Shared.Business.DTOs;
using Backend.Business.Services;
using Frontend.Web.Core.Controllers;
using System.Linq;
using System.Web.Http.OData;
using Backend.Business.Context;

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

        [EnableQuery]
        public override IQueryable<UserDTO> Get()
        {
            return Service.GetActive();
        }

        public IQueryable<UserDTO> GetByName(string username)
        {
            THBContext db = new THBContext();
            var result = db.ModelerUsers.SingleOrDefault(u => u.UserName == username);
            return (IQueryable<UserDTO>)result;
        }
    }
}
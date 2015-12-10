using System.Linq;
using System.Web.Http;
using System.Web.Http.OData;
using GoldenEye.Backend.Business.Context;
using GoldenEye.Backend.Business.Services;
using GoldenEye.Frontend.Core.Web.Controllers;
using GoldenEye.Shared.Core.DTOs;

namespace GoldenEye.Frontend.Web.Controllers
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
            SampleContext db = new SampleContext();
            var result = db.ModelerUsers.SingleOrDefault(u => u.UserName == username);
            return (IQueryable<UserDTO>)result;
        }
    }
}
using System.Web.Http;
using Shared.Business.DTOs;
using Backend.Business.Services;
using Frontend.Web.Core.Controllers;
using System.Threading.Tasks;
using System.Linq;
using Backend.Business.Context;
using AutoMapper;
using Backend.Business.Entities;

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
        public IQueryable<UserDTO> GetByName(string username)
        {
            THBContext db = new THBContext();
            var result = db.ModelerUsers.SingleOrDefault(u => u.UserName == username);
            return (IQueryable<UserDTO>)result;
        }
    }
}
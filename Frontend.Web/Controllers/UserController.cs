using System;
using System.Linq;
using System.Web.Http;
using System.Web.Http.OData;
using GoldenEye.Backend.Business.Context;
using GoldenEye.Backend.Business.Services;
using GoldenEye.Backend.Security.Service;
using GoldenEye.Frontend.Core.Web.Controllers;
using GoldenEye.Shared.Core.DTOs;

namespace GoldenEye.Frontend.Web.Controllers
{
    [Authorize]
    public class UserController : ReadonlyRestControllerBase<IUserRestService, UserDTO>
    {
        public UserController()
        {
        }

        public UserController(IUserRestService service)
            : base(service)
        {
        }

        [EnableQuery]
        public override IQueryable<UserDTO> Get()
        {
            return Service.Get();
        }

        public IQueryable<UserDTO> GetByName(string username)
        {
            throw new NotImplementedException();
        }
    }
}
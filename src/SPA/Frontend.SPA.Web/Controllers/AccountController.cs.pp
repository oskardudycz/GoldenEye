using System.Web.Http;
using GoldenEye.Backend.Security.Managers;
using GoldenEye.Backend.Security.Model;
using GoldenEye.Frontend.Security.Web.Controllers;
using Microsoft.Owin.Security;

namespace $rootnamespace$.Controllers
{
    [Authorize]
    [RoutePrefix("api/Account")]
    public class AccountController : AccountControllerBase
    {
        public AccountController()
        {
        }

        public AccountController(IUserManager<User> userManager,
            ISecureDataFormat<AuthenticationTicket> accessTokenFormat) : base(userManager, accessTokenFormat)
        {
        }
    }
}
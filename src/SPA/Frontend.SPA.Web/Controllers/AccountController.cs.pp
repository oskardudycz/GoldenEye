using System.Web.Http;
using GoldenEye.Frontend.Security.Web.Controllers;

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
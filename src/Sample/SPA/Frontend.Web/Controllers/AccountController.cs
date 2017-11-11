using System.Web.Http;
using GoldenEye.Frontend.Security.Web.Controllers;

namespace GoldenEye.Frontend.Web.Controllers
{
    [Authorize]
    [RoutePrefix("api/Account")]
    public class AccountController : AccountControllerBase
    {
    }
}
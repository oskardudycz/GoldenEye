using System.Web.Http;
using GoldenEye.Security.Core.Controllers;

namespace GoldenEye.Frontend.Web.Controllers
{
    [Authorize]
    [RoutePrefix("api/Account")]
    public class AccountController : AccountControllerBase
    {
    }
}
using System.Web.Http;
using GoldenEye.Frontend.Core.Web.Controllers;

namespace GoldenEye.Frontend.Web.Controllers
{
    [Authorize]
    [RoutePrefix("api/Account")]
    public class AccountController : AccountControllerBase
    {
    }
}
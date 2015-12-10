using System.Web.Http;
using GoldenEye.Backend.Business.Services;
using GoldenEye.Frontend.Core.Web.Controllers;
using GoldenEye.Shared.Business.DTOs;

namespace GoldenEye.Frontend.Web.Controllers
{
    [Authorize]
    public class CustomerController : ReadonlyRestControllerBase<ICustomerRestService, CustomerDTO>
    {
        public CustomerController()
        {
        }

        public CustomerController(ICustomerRestService service)
            : base(service)
        {
        }
    }
}

using System.Web.Http;
using Frontend.Web.Core.Controllers;
using Shared.Business.DTOs;
using Backend.Business.Services;

namespace Frontend.Web.Controllers
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

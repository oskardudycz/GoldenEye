using System.Web.Http;
using Shared.Business.DTOs;
using Backend.Business.Services;
using Frontend.Web.Core.Controllers;

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

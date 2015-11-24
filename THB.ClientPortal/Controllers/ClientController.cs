using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Frontend.Web.Core.Controllers;
using Shared.Business.DTOs;
using Backend.Business.Services;

namespace Frontend.Web.Controllers
{
    public class ClientController : ReadonlyRestControllerBase<IClientRestService, ClientDTO>
    {
        public ClientController()
        {
        }

        public ClientController(IClientRestService service)
            : base(service)
        {
        }
    }
}

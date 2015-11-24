using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Shared.Business.DTOs;
using Backend.Business.Entities;
using Backend.Core.Service;
using Backend.Business.Repository;

namespace Backend.Business.Services
{
    public class ClientRestService : ReadonlyRestServiceBase<ClientDTO, ClientEntity>, IClientRestService
    {
        public ClientRestService(IClientRepository repository)
            : base(repository)
        {
        }
    }
}
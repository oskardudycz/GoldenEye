using System.Data.Entity;
using Backend.Core.Repository;
using Backend.Business.Entities;
using Backend.Business.Context;

namespace Backend.Business.Repository
{
    public class ClientRepository : ReadonlyRepositoryBase<ClientEntity>, IClientRepository
    {
        public ClientRepository(ITHBContext context)
            : base(context, context.Clients)
        {
        }
    }
}
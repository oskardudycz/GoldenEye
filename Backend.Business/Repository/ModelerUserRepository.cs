using System.Data.Entity;
using Backend.Core.Repository;
using Backend.Business.Entities;
using Backend.Business.Context;

namespace Backend.Business.Repository
{
    public class ModelerUserRepository : ReadonlyRepositoryBase<ModelerUserEntity>, IModelerUserRepository
    {
        public ModelerUserRepository(ITHBContext context)
            : base(context, context.ModelerUsers)
        {
        }
    }
}
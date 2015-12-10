using System.Data.Entity;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Core.Repository;

namespace GoldenEye.Backend.Business.Repository
{
    public class UserRepository : RepositoryBase<UserEntity>, IUserRepository
    {
        public UserRepository(IDataContext context, IDbSet<UserEntity> dbSet) : base(context, dbSet)
        {
        }
    }
}
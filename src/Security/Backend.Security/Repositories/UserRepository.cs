using GoldenEye.Backend.Core.Repository;
using GoldenEye.Backend.Security.DataContext;
using GoldenEye.Backend.Security.Model;

namespace GoldenEye.Backend.Security.Repositories
{
    public class UserRepository : RepositoryBase<User>, IUserRepository
    {
        public UserRepository(IUserDataContext context) : base(context, context.Users)
        {
        }
    }
}
using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Security.Model;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.DataContext.Base
{
    public abstract class UserDataContextBase<T> : IdentityDbContext<T, Role, int, UserLogin, UserRole, UserClaim>, IUserDataContext<T> where T : IdentityUser<int, UserLogin, UserRole, UserClaim>
    {
        protected UserDataContextBase()
            : base("DBConnectionString")
        {

        }

        protected UserDataContextBase(string connectionString)
            : base(connectionString)
        {

        }

        protected UserDataContextBase(IConnectionProvider connectionProvider)
            : base(connectionProvider.Open(), false)
        {

        }
    }
}
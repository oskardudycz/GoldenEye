using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Security.Model;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.DataContext
{
    public class UserDataContext : UserDataContext<User>, IUserDataContext
    {
        public UserDataContext()
        {

        }

        public UserDataContext(IConnectionProvider connectionProvider)
            : base(connectionProvider)
        {

        }

        public static UserDataContext Create()
        {
            return new UserDataContext();
        }
    }

    public abstract class UserDataContext<T> : IdentityDbContext<T, Role, int, UserLogin, UserRole, UserClaim>, IUserDataContext<T> where T : IdentityUser<int, UserLogin, UserRole, UserClaim>
    {
        protected UserDataContext()
            : base("DBConnectionString")
        {

        }

        protected UserDataContext(string connectionString)
            : base(connectionString)
        {

        }

        protected UserDataContext(IConnectionProvider connectionProvider)
            : base(connectionProvider.Open(), false)
        {

        }
    }
}

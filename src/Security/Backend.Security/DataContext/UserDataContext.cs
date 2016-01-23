using GoldenEye.Backend.Security.Model;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.DataContext
{
    public class UserDataContext : IdentityDbContext<User, Role, int, UserLogin, UserRole, UserClaim>, IUserDataContext
    {
        public UserDataContext()
            : base("DBConnectionString")
        {

        }

        public static UserDataContext Create()
        {
            return new UserDataContext();
        }
    }
}

using GoldenEye.Backend.Security.DataContext;
using GoldenEye.Backend.Security.Model;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.Stores
{
    public class UserStore : UserStore<User, Role, int, UserLogin, UserRole, UserClaim>
    {
        public UserStore(UserDataContext context)
            : base(context)
        {
        }
    }
}

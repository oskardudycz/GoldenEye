using System.Data.Entity;
using GoldenEye.Backend.Security.DataContext;
using GoldenEye.Backend.Security.Model;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.Stores
{
    public class UserStore : UserStore<User>
    {
        public UserStore(IUserDataContext<User> context)
            : base(context)
        {
        }
    }

    public class UserStore<TUser> : UserStore<TUser, Role, int, UserLogin, UserRole, UserClaim>, IUserStore<TUser> 
        where TUser : IdentityUser<int, UserLogin, UserRole, UserClaim>, IUser<int>
    {
        public UserStore(IUserDataContext<TUser> context)
            : base((DbContext) context)
        {
        }
    }
}

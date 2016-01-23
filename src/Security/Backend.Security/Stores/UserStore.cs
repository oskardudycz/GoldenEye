using System.Data.Entity;
using GoldenEye.Backend.Security.Model;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.Stores
{
    public class UserStore : UserStoreBase<User>
    {
        public UserStore(DbContext context)
            : base(context)
        {
        }
    }

    public abstract class UserStoreBase<TUser> : UserStore<TUser, Role, int, UserLogin, UserRole, UserClaim>, IUserStore<TUser> 
        where TUser : IdentityUser<int, UserLogin, UserRole, UserClaim>
    {
        protected UserStoreBase(DbContext context)
            : base(context)
        {
        }
    }
}

using System.Data.Entity;
using GoldenEye.Backend.Security.DataContext;
using GoldenEye.Backend.Security.Model;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.Stores
{
    public class UserStore : UserStoreBase<User>
    {
        public UserStore(UserDataContext context)
            : base(context)
        {
        }
    }

    public abstract class UserStoreBase<T> : UserStore<T, Role, int, UserLogin, UserRole, UserClaim> 
        where T : IdentityUser<int, UserLogin, UserRole, UserClaim>
    {
        protected UserStoreBase(DbContext context)
            : base(context)
        {
        }
    }
}

using GoldenEye.Backend.Security.DataContext;
using GoldenEye.Backend.Security.Model;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.Stores
{
    public class RoleStore : RoleStore<Role, int, UserRole>
    {
        public RoleStore(UserDataContext context)
            : base(context)
        {
        }
    }
}

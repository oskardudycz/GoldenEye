using GoldenEye.Security.Core.Model;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Security.Core.DataContext
{
    public class UserDataContext : IdentityDbContext<User>
    {
        public UserDataContext()
            : base("DBConnectionString", throwIfV1Schema: false)
        {

        }
    }
}

using GoldenEye.Backend.Security.Model;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.DataContext
{
    public class UserDataContext : IdentityDbContext<User>
    {
        public UserDataContext()
            : base("DBConnectionString", throwIfV1Schema: false)
        {

        }
    }
}

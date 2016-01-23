using System.Data.Entity;
using GoldenEye.Backend.Security.Model;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.Stores
{
    public class RoleStore : RoleStore<Role, int, UserRole>
    {
        public RoleStore(DbContext context)
            : base(context)
        {
        }
    }
}

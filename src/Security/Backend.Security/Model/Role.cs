using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.Model
{
    public class Role : IdentityRole<int, UserRole>
    {
        public Role() { }
        public Role(string name) { Name = name; }
    }
}

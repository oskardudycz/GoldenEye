using Microsoft.EntityFrameworkCore;

namespace GoldenEye.Backend.Identity.Storage
{
    public class ApplicationDbContext: Microsoft.AspNetCore.Identity.EntityFrameworkCore.IdentityDbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }
    }
}

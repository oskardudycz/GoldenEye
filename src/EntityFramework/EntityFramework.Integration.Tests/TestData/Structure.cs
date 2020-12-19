using GoldenEye.EntityFramework.Repositories;
using GoldenEye.Objects.General;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace GoldenEye.EntityFramework.Integration.Tests.TestData
{
    public class User: IHaveId
    {
        public int Id { get; set; }

        public string UserName { get; set; }
        public string FullName { get; set; }
        object IHaveId.Id => Id;
    }

    public class UsersDbContext: DbContext
    {
        public UsersDbContext(DbContextOptions<UsersDbContext> options)
            : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.HasDefaultSchema("eftest_users");
            modelBuilder.Entity<User>();
        }

        public DbSet<User> Users { get; set; }
    }

    public class UsersDesignTypeDbContextFactory: DesignTypeDbContextFactory<UsersDbContext>
    {
        protected override UsersDbContext Get(IConfigurationRoot configuration, string connectionString, DbContextOptionsBuilder<UsersDbContext> optionsBuilder)
        {
            optionsBuilder.UseNpgsql(connectionString);

            return new UsersDbContext(optionsBuilder.Options);
        }
    }
}

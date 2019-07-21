using GoldenEye.Backend.Core.EntityFramework.Context;
using GoldenEye.Backend.Identity.Storage;
using IdentityServer4.EntityFramework.Options;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace Frontend.Identity.Sample
{
    public class DesignConfigurationDbContextFactory: DesignTypeDbContextFactoryBase<IdentityServer4.EntityFramework.DbContexts.ConfigurationDbContext>
    {
        protected override IdentityServer4.EntityFramework.DbContexts.ConfigurationDbContext Get(IConfigurationRoot configuration, DbContextOptionsBuilder<IdentityServer4.EntityFramework.DbContexts.ConfigurationDbContext> builder)
        {
            var connectionString = configuration.GetConnectionString("IdentityDatabase");
            builder.UseNpgsql(connectionString, b => b.MigrationsAssembly("Backend.Identity.Sample"));

            return new IdentityServer4.EntityFramework.DbContexts.ConfigurationDbContext(builder.Options, new ConfigurationStoreOptions());
        }
    }

    public class DesignPersistedGrantDbContextFactory: DesignTypeDbContextFactoryBase<IdentityServer4.EntityFramework.DbContexts.PersistedGrantDbContext>
    {
        protected override IdentityServer4.EntityFramework.DbContexts.PersistedGrantDbContext Get(IConfigurationRoot configuration, DbContextOptionsBuilder<IdentityServer4.EntityFramework.DbContexts.PersistedGrantDbContext> builder)
        {
            var connectionString = configuration.GetConnectionString("IdentityDatabase");
            builder.UseNpgsql(connectionString, b => b.MigrationsAssembly("Backend.Identity.Sample"));

            return new IdentityServer4.EntityFramework.DbContexts.PersistedGrantDbContext(builder.Options, new OperationalStoreOptions());
        }
    }

    public class ApplicationDbContextFactory: DesignTypeDbContextFactoryBase<ApplicationDbContext>
    {
        protected override ApplicationDbContext Get(IConfigurationRoot configuration, DbContextOptionsBuilder<ApplicationDbContext> builder)
        {
            var connectionString = configuration.GetConnectionString("IdentityDatabase");
            builder.UseNpgsql(connectionString, b => b.MigrationsAssembly("Backend.Identity.Sample"));

            return new ApplicationDbContext(builder.Options);
        }
    }
}

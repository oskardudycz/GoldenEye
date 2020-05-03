using System.IO;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace GoldenEye.Backend.Core.EntityFramework.Context
{
    public abstract class DesignTypeDbContextFactoryBase<TDbContext>: IDesignTimeDbContextFactory<TDbContext>
        where TDbContext : DbContext
    {
        public virtual TDbContext CreateDbContext(string[] args)
        {
            var builder = new DbContextOptionsBuilder<TDbContext>();
            var configuration = GetConfiguration();

            return Get(configuration, builder);
        }

        protected IConfigurationRoot GetConfiguration()
        {
            var configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json")
                .Build();

            return configuration;
        }

        protected abstract TDbContext Get(IConfigurationRoot configuration,
            DbContextOptionsBuilder<TDbContext> builder);
    }
}

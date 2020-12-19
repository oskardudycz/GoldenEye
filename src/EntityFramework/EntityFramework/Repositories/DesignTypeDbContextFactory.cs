using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace GoldenEye.EntityFramework.Repositories
{
    public abstract class DesignTypeDbContextFactory<TDbContext>: IDesignTimeDbContextFactory<TDbContext>
        where TDbContext : DbContext
    {
        protected virtual string ConfigurationConnectionStringKey { get; } = "DefaultConnection";
        protected virtual string EnvConnectionStringKey { get; } = "DefaultConnection";

        public virtual TDbContext CreateDbContext(string[] args)
        {
            var builder = new DbContextOptionsBuilder<TDbContext>();
            var configuration = GetConfiguration();
            var connectionString = GetDefaultConnectionString(configuration);

            return Get(configuration, connectionString, builder);
        }

        protected virtual IConfigurationRoot GetConfiguration()
        {
            var environmentName = Environment.GetEnvironmentVariable("EnvironmentName") ?? "Development";

            var configuration = new ConfigurationBuilder()
                .SetBasePath(AppContext.BaseDirectory)
                .AddJsonFile("appsettings.json")
                .AddJsonFile($"appsettings.{environmentName}.json", optional: true, reloadOnChange: false)
                .Build();

            return configuration;
        }

        protected virtual string GetDefaultConnectionString(IConfigurationRoot configuration)
        {
            var connectionStringFromConfig = configuration
                .GetConnectionString(ConfigurationConnectionStringKey);

            var connectionStringFromEnv = Environment.GetEnvironmentVariable(EnvConnectionStringKey);

            return connectionStringFromConfig ?? connectionStringFromEnv;
        }

        protected abstract TDbContext Get(IConfigurationRoot configuration,
            string connectionString,
            DbContextOptionsBuilder<TDbContext> builder);
    }
}

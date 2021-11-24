using Backend.DDD.Sample.Contracts.Issues.Views;
using Backend.DDD.Sample.Issues;
using Backend.DDD.Sample.Issues.Projections;
using GoldenEye.Marten.Events.Storage;
using GoldenEye.Marten.Registration;
using GoldenEye.Registration;
using Marten;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using IssueContracts = Backend.DDD.Sample.Contracts.Issues;

namespace Backend.DDD.Sample
{
    public class Module: GoldenEye.Modules.Module
    {
        private readonly IConfiguration configuration;

        public Module(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public override void Configure(IServiceCollection services)
        {
            ConfigureIntrastructure(services);
            RegisterHandlers(services);
            base.Configure(services);
        }

        private void ConfigureIntrastructure(IServiceCollection services)
        {
            var connectionString = configuration.GetConnectionString("DDDSample") ??
                                   "PORT = 5432; HOST = 127.0.0.1; TIMEOUT = 15; POOLING = True; MINPOOLSIZE = 1; MAXPOOLSIZE = 100; COMMANDTIMEOUT = 20; DATABASE = 'postgres'; PASSWORD = 'Password12!'; USER ID = 'postgres'";

            services.AddMarten(sp => connectionString, SetupEventStore, "DDDSample");
            services.AddEventStore<MartenEventStore>();
            services.AddEventStorePipeline();
            services.AddValidationPipeline();
        }

        private void SetupEventStore(StoreOptions options)
        {
            options.Projections.SelfAggregate<Issue>();
            options.Projections.Add(new IssueProjection());
        }

        private void RegisterHandlers(IServiceCollection services)
        {
            services.AddMartenDocumentRepository<Issue>();
            services.AddMartenDocumentReadonlyRepository<IssueView>();
        }
    }
}

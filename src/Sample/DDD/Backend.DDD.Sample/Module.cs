using Backend.DDD.Sample.Issues;
using Backend.DDD.Sample.Issues.Projections;
using GoldenEye.Backend.Core.DDD.Registration;
using GoldenEye.Backend.Core.Marten.Events.Storage;
using GoldenEye.Backend.Core.Marten.Registration;
using Marten;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using IssueContracts = Backend.DDD.Sample.Contracts.Issues;

namespace Backend.DDD.Sample
{
    public class Module: GoldenEye.Shared.Core.Modules.Module
    {
        private IConfiguration configuration;

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

        public override void Use()
        {
            base.Use();
        }

        private void ConfigureIntrastructure(IServiceCollection services)
        {
            var connectionString = configuration.GetConnectionString("DDDSample") ?? "PORT = 5432; HOST = 127.0.0.1; TIMEOUT = 15; POOLING = True; MINPOOLSIZE = 1; MAXPOOLSIZE = 100; COMMANDTIMEOUT = 20; DATABASE = 'postgres'; PASSWORD = 'Password12!'; USER ID = 'postgres'";

            services.AddMartenContext(sp => connectionString, SetupEventStore, schemaName: "DDDSample");
            services.AddEventStore<MartenEventStore>();
            services.AddEventStorePipeline();
            services.AddValidationPipeline();
            services.AddMartenDocumentDataContext();
        }

        private void SetupEventStore(StoreOptions options)
        {
            options.Events.InlineProjections.AggregateStreamsWith<Issue>();
            options.Events.InlineProjections.Add(new IssueProjection());
        }

        private void RegisterHandlers(IServiceCollection services)
        {
            services.AddMartenDocumentCRUDRepository<Issue>();
            services.AddMartenDocumentReadonlyRepository<IssueContracts.Views.IssueView>();
        }
    }
}

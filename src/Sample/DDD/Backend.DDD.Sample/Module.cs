using System.Collections.Generic;
using Backend.DDD.Contracts.Sample.Issues.Commands;
using Backend.DDD.Contracts.Sample.Issues.Queries;
using Backend.DDD.Sample.Issues;
using Backend.DDD.Sample.Issues.Handlers;
using GoldenEye.Backend.Core.DDD.Registration;
using GoldenEye.Backend.Core.Marten.Events.Storage;
using GoldenEye.Backend.Core.Marten.Registration;
using GoldenEye.Shared.Core.Modules;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using IssueContracts = Backend.DDD.Contracts.Sample.Issues;

namespace Backend.DDD.Sample
{
    public class Module : ModuleBase
    {
        public Module(IConfiguration configuration) : base(configuration)
        {
        }

        public override void Configure(IServiceCollection services)
        {
            ConfigureIntrastructure(services);
            RegisterHandlers(services);
            base.Configure(services);
        }

        public override void OnStartup()
        {
            base.OnStartup();
        }

        private void ConfigureIntrastructure(IServiceCollection services)
        {
            var connectionString = configuration.GetConnectionString("DDDSample") ?? "PORT = 5432; HOST = 127.0.0.1; TIMEOUT = 15; POOLING = True; MINPOOLSIZE = 1; MAXPOOLSIZE = 100; COMMANDTIMEOUT = 20; DATABASE = 'postgres'; PASSWORD = 'postgres'; USER ID = 'postgres'";

            services.AddMartenContext(sp => connectionString, schemaName: "DDDSample");
            services.AddEventStore<MartenEventStore>();
            services.AddEventStorePipeline();
            services.AddMartenDocumentDataContext();

            services.AddMartenDocumentCRUDRepository<Issue>();
        }

        private void RegisterHandlers(IServiceCollection services)
        {
            ////issues
            services.RegisterAsyncQueryHandler<GetIssues, IReadOnlyList<IssueContracts.Issue>, IssueQueryHandler>();
            services.RegisterAsyncQueryHandler<GetIssue, IssueContracts.Issue, IssueQueryHandler>();
            services.RegisterAsyncCommandHandler<CreateIssue, IssueCommandHandler>();
        }
    }
}
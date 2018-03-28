using System.Collections.Generic;
using Backend.Contracts.Issues.Commands;
using Backend.Contracts.Issues.Queries;
using Backend.Issues;
using Backend.Issues.Handlers;
using Backend.Issues.Projections;
using GoldenEye.Backend.Core.DDD.Registration;
using GoldenEye.Backend.Core.Marten.Events.Storage;
using GoldenEye.Backend.Core.Marten.Registration;
using GoldenEye.Shared.Core.Modules;
using Marten;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using IssueContracts = Backend.Contracts.Issues;

namespace Backend
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

            services.AddMartenContext(sp => connectionString, SetupEventStore, schemaName: "DDDSample");
            services.AddEventStore<MartenEventStore>();
            services.AddEventStorePipeline();
            services.AddValidationPipeline();
            services.AddMartenDocumentDataContext();

            services.AddMartenDocumentCRUDRepository<Issue>();
        }

        private void SetupEventStore(StoreOptions options)
        {
            options.Events.InlineProjections.AggregateStreamsWith<Issue>();
            options.Events.InlineProjections.Add(new IssueProjection());
        }

        private void RegisterHandlers(IServiceCollection services)
        {
             services.AddMartenDocumentReadonlyRepository<IssueContracts.Views.IssueView>();
            services.RegisterQueryHandler<GetIssues, IReadOnlyList<IssueContracts.Views.IssueView>, IssueQueryHandler>();
            services.RegisterQueryHandler<GetIssue, IssueContracts.Views.IssueView, IssueQueryHandler>();
            services.RegisterCommandHandler<CreateIssue, IssueCommandHandler>();
        }
    }
}
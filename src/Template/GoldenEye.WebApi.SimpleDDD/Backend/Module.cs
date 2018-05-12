using System.Collections.Generic;
using Backend.Issues;
using Backend.Issues.Handlers;
using Backend.Issues.Projections;
using Contracts.Issues.Commands;
using Contracts.Issues.Queries;
using Contracts.Issues.Views;
using GoldenEye.Backend.Core.DDD.Registration;
using GoldenEye.Backend.Core.Marten.Events.Storage;
using GoldenEye.Backend.Core.Marten.Registration;
using GoldenEye.Backend.Core.Registration;
using GoldenEye.Shared.Core.Modules;
using Marten;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Backend
{
    public class BackendModule : Module
    {
        private readonly IConfiguration _configuration;

        public BackendModule(IConfiguration configuration)
        {
            _configuration = configuration;
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
            var connectionString = _configuration.GetConnectionString("DDDSample") ?? "PORT = 5432; HOST = 127.0.0.1; TIMEOUT = 15; POOLING = True; MINPOOLSIZE = 1; MAXPOOLSIZE = 100; COMMANDTIMEOUT = 20; DATABASE = 'postgres'; PASSWORD = 'Password12!'; USER ID = 'postgres'";

            services.AddMartenContext(sp => connectionString, SetupEventStore, schemaName: "DDDSample");
            services.AddEventStore<MartenEventStore>();
            services.AddEventStorePipeline();
            services.AddValidationPipeline();
            services.AddAllValidators();
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
            services.RegisterCommandHandler<CreateIssue, IssueCommandHandler>();
            services.RegisterCommandHandler<UpdateIssue, IssueCommandHandler>();

            services.AddMartenDocumentReadonlyRepository<IssueView>();
            services.RegisterQueryHandler<GetIssues, IReadOnlyList<IssueView>, IssueQueryHandler>();
            services.RegisterQueryHandler<GetIssue, IssueView, IssueQueryHandler>();
        }
    }
}
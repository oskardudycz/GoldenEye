using System;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.DDD.Events;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Extensions.Mapping;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Commands;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Events;

namespace GoldenEye.WebApi.Template.SimpleDDD.Backend.Issues.Handlers
{
    internal class IssueCommandHandler :
        ICommandHandler<CreateIssue>,
        ICommandHandler<UpdateIssue>,
        ICommandHandler<DeleteIssue>
    {
        private IEventBus eventBus;
        private IRepository<Issue> repository;

        public IssueCommandHandler(
            IEventBus eventBus,
            IRepository<Issue> repository)
        {
            this.eventBus = eventBus ?? throw new ArgumentException(nameof(eventBus));
            this.repository = repository ?? throw new ArgumentException(nameof(repository));
        }

        public async Task Handle(CreateIssue command, CancellationToken cancellationToken)
        {
            var issue = command.Map<Issue>();
            await repository.AddAsync(issue, cancellationToken);

            var @event = issue.Map<IssueCreated>();
            await eventBus.PublishAsync(@event, cancellationToken);
        }

        public async Task Handle(UpdateIssue command, CancellationToken cancellationToken)
        {
            var issue = await repository.GetByIdAsync(command.Id, cancellationToken);
            issue.MapFrom(command);
            await repository.UpdateAsync(issue, cancellationToken);

            var @event = issue.Map<IssueUpdated>();
            await eventBus.PublishAsync(@event, cancellationToken);
        }

        public async Task Handle(DeleteIssue command, CancellationToken cancellationToken)
        {
            await repository.DeleteAsync(command.Id, cancellationToken);

            await eventBus.PublishAsync(new IssueDeleted(command.Id));
        }
    }
}
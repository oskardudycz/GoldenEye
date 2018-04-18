using System;
using System.Threading;
using System.Threading.Tasks;
using Contracts.Issues.Commands;
using Contracts.Issues.Events;
using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.DDD.Events;
using GoldenEye.Shared.Core.Extensions.Mapping;

namespace Backend.Issues.Handlers
{
    internal class IssueCommandHandler
        : ICommandHandler<CreateIssue>
    {
        private IEventBus eventBus;

        public IssueCommandHandler( IEventBus eventBus )
        {
            this.eventBus = eventBus ?? throw new ArgumentException(nameof(eventBus));
        }

        public async Task Handle(CreateIssue command, CancellationToken cancellationToken)
        {
            var issue = command.Map<Issue>();
            var @event = issue.Map<IssueCreated>();
            await eventBus.Publish(@event);
        }
    }
}
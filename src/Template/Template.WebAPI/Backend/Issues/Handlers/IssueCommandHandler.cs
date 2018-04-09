using System;
using System.Threading;
using System.Threading.Tasks;
using Backend.Contracts.Issues.Commands;
using Backend.Contracts.Issues.Events;
using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.DDD.Events;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Extensions.Mapping;

namespace Backend.Issues.Handlers
{
    internal class IssueCommandHandler
        : ICommandHandler<CreateIssue>
    {
        private IEventBus eventBus;

        public IssueCommandHandler( IEventBus eventBus )
        {
            this.eventBus = eventBus;
        }

        public async Task Handle(CreateIssue message, CancellationToken cancellationToken)
        {
            var issue = message.Map<Issue>();
            var @event = issue.Map<IssueCreated>();
            await eventBus.Publish(@event);
           
        }
    }
}
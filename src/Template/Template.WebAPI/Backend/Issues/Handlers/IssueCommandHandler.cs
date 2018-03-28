using System;
using System.Threading;
using System.Threading.Tasks;
using Backend.Contracts.Issues.Commands;
using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Extensions.Mapping;

namespace Backend.Issues.Handlers
{
    internal class IssueCommandHandler
        : ICommandHandler<CreateIssue>
    {
        private readonly IRepository<Issue> repository;

        public IssueCommandHandler(
            IRepository<Issue> repository
        )
        {
            this.repository = repository ?? throw new ArgumentException(nameof(repository));
        }

        public async Task Handle(CreateIssue message, CancellationToken cancellationToken)
        {
            var aggregate = message.Map<Issue>();

            await repository.AddAsync(aggregate);
            await repository.SaveChangesAsync();
        }
    }
}
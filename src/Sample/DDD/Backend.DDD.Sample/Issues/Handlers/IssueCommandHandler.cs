using System;
using System.Threading;
using System.Threading.Tasks;
using Backend.DDD.Sample.Contracts.Issues.Commands;
using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Extensions.Mapping;
using MediatR;

namespace Backend.DDD.Sample.Issues.Handlers
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

        public async Task<Unit> Handle(CreateIssue message, CancellationToken cancellationToken)
        {
            var aggregate = message.Map<Issue>();

            await repository.AddAsync(aggregate);
            await repository.SaveChangesAsync();

            return Unit.Value;
        }
    }
}
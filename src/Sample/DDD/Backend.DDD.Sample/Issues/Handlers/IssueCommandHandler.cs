using System;
using System.Threading.Tasks;
using Backend.DDD.Sample.Contracts.Issues.Commands;
using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Extensions.Mapping;

namespace Backend.DDD.Sample.Issues.Handlers
{
    internal class IssueCommandHandler
        : IAsyncCommandHandler<CreateIssue>
    {
        private readonly IRepository<Issue> repository;

        public IssueCommandHandler(
            IRepository<Issue> repository
        )
        {
            this.repository = repository ?? throw new ArgumentException(nameof(repository));
        }

        public async Task Handle(CreateIssue message)
        {
            var aggregate = message.Map<Issue>();

            await repository.AddAsync(aggregate);
            await repository.SaveChangesAsync();
        }
    }
}
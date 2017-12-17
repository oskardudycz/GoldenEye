using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using AutoMapper.QueryableExtensions;
using Backend.DDD.Contracts.Sample.Issues.Queries;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Extensions.Mapping;
using Marten;
using IssueContracts = Backend.DDD.Contracts.Sample.Issues;

namespace Backend.DDD.Sample.Issues.Handlers
{
    internal class IssueQueryHandler :
        IAsyncQueryHandler<GetIssues, IReadOnlyList<IssueContracts.Issue>>,
        IAsyncQueryHandler<GetIssue, IssueContracts.Issue>
    {
        private readonly IReadonlyRepository<Issue> repository;

        public IssueQueryHandler(IReadonlyRepository<Issue> repository)
        {
            this.repository = repository ?? throw new ArgumentException(nameof(repository));
        }

        public Task<IReadOnlyList<IssueContracts.Issue>> Handle(GetIssues message)
        {
            return repository
                .GetAll()
                .ProjectTo<IssueContracts.Issue>()
                .ToListAsync();
        }

        public async Task<IssueContracts.Issue> Handle(GetIssue message)
        {
            var aggregate = await repository.GetByIdAsync(message.Id);

            return aggregate.Map<IssueContracts.Issue>();
        }
    }
}
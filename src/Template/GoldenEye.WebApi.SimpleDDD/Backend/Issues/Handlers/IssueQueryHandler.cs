using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper.QueryableExtensions;
using Contracts.Issues.Queries;
using Contracts.Issues.Views;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Extensions.Mapping;
using Marten;

namespace Backend.Issues.Handlers
{
    internal class IssueQueryHandler :
        IQueryHandler<GetIssues, IReadOnlyList<IssueView>>,
        IQueryHandler<GetIssue, IssueView>
    {
        private readonly IReadonlyRepository<Issue> repository;

        public IssueQueryHandler(IReadonlyRepository<Issue> repository)
        {
            this.repository = repository ?? throw new ArgumentException(nameof(repository));
        }

        public async Task<IReadOnlyList<IssueView>> Handle(GetIssues message, CancellationToken cancellationToken)
        {
            return await repository
                .GetAll()
                .ProjectTo<IssueView>()
                .ToListAsync();
        }

        public async Task<IssueView> Handle(GetIssue message, CancellationToken cancellationToken)
        {
            var entity = await repository.GetByIdAsync(message.Id);

            return entity.Map<IssueView>();
        }
    }
}
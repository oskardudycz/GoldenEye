using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper.QueryableExtensions;
using Backend.DDD.Sample.Contracts.Issues.Queries;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Extensions.Mapping;
using Marten;
using IssueViews = Backend.DDD.Sample.Contracts.Issues.Views;

namespace Backend.DDD.Sample.Issues.Handlers
{
    internal class IssueQueryHandler :
        IQueryHandler<GetIssues, IReadOnlyList<IssueViews.IssueView>>,
        IQueryHandler<GetIssue, IssueViews.IssueView>
    {
        private readonly IReadonlyRepository<Issue> repository;

        public IssueQueryHandler(IReadonlyRepository<Issue> repository)
        {
            this.repository = repository ?? throw new ArgumentException(nameof(repository));
        }

        public Task<IReadOnlyList<IssueViews.IssueView>> Handle(GetIssues message, CancellationToken cancellationToken)
        {
            return repository
                .GetAll()
                .ProjectTo<IssueViews.IssueView>()
                .ToListAsync();
        }

        public async Task<IssueViews.IssueView> Handle(GetIssue message, CancellationToken cancellationToken)
        {
            var entity = await repository.GetByIdAsync(message.Id);

            return entity.Map<IssueViews.IssueView>();
        }
    }
}
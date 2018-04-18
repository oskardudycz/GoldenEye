using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Contracts.Issues.Queries;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.Backend.Core.Repositories;
using Marten;
using IssueViews = Contracts.Issues.Views;

namespace Backend.Issues.Handlers
{
    internal class IssueQueryHandler :
        IQueryHandler<GetIssues, IReadOnlyList<IssueViews.IssueView>>,
        IQueryHandler<GetIssue, IssueViews.IssueView>
    {
        private readonly IReadonlyRepository<IssueViews.IssueView> repository;

        public IssueQueryHandler(IReadonlyRepository<IssueViews.IssueView> repository)
        {
            this.repository = repository ?? throw new ArgumentException(nameof(repository));
        }

        public Task<IReadOnlyList<IssueViews.IssueView>> Handle(GetIssues message, CancellationToken cancellationToken)
        {
            return repository
                .GetAll()
                .ToListAsync();
        }

        public Task<IssueViews.IssueView> Handle(GetIssue message, CancellationToken cancellationToken)
        {
            return repository.GetByIdAsync(message.Id);
        }
    }
}
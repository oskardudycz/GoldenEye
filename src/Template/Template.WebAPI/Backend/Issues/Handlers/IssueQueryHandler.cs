using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Backend.Contracts.Issues.Queries;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.Backend.Core.Repositories;
using Marten;
using IssueViews = Backend.Contracts.Issues.Views;

namespace Backend.Issues.Handlers
{
    public class IssueQueryHandler :
        IQueryHandler<GetIssues, IReadOnlyList<IssueViews.Issue>>,
        IQueryHandler<GetIssue, IssueViews.Issue>
    {
        private readonly IReadonlyRepository<Issue> repository;

        public IssueQueryHandler(IRepository<Issue> repository)
        {
            this.repository = repository ?? throw new ArgumentException(nameof(repository));
        }

        public Task<IReadOnlyList<IssueViews.Issue>> Handle(GetIssues message, CancellationToken cancellationToken)
        {
            return null;
        }

        public Task<IssueViews.Issue> Handle(GetIssue message, CancellationToken cancellationToken)
        {
            return null;
        }
    }
}
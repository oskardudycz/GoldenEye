using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Queries;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Views;
using Marten;

namespace GoldenEye.WebApi.Template.SimpleDDD.Backend.Issues.Handlers
{
    internal class IssueQueryHandler:
        IQueryHandler<GetIssues, IReadOnlyList<IssueView>>,
        IQueryHandler<GetIssue, IssueView>
    {
        private readonly IReadonlyRepository<IssueView> repository;

        public IssueQueryHandler(IReadonlyRepository<IssueView> repository)
        {
            this.repository = repository ?? throw new ArgumentException(nameof(repository));
        }

        public Task<IReadOnlyList<IssueView>> Handle(GetIssues message, CancellationToken cancellationToken)
        {
            return repository
                .GetAll()
                .ToListAsync();
        }

        public Task<IssueView> Handle(GetIssue message, CancellationToken cancellationToken)
        {
            return repository.GetByIdAsync(message.Id);
        }
    }
}

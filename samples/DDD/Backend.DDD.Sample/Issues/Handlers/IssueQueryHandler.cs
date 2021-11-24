using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Backend.DDD.Sample.Contracts.Issues.Queries;
using GoldenEye.Queries;
using GoldenEye.Repositories;
using Marten;
using IssueViews = Backend.DDD.Sample.Contracts.Issues.Views;

namespace Backend.DDD.Sample.Issues.Handlers;

internal class IssueQueryHandler:
    IQueryHandler<GetIssues, IReadOnlyList<IssueViews.IssueView>>,
    IQueryHandler<GetIssue, IssueViews.IssueView>
{
    private readonly IConfigurationProvider configurationProvider;
    private readonly IMapper mapper;
    private readonly IReadonlyRepository<Issue> repository;

    public IssueQueryHandler(
        IReadonlyRepository<Issue> repository,
        IConfigurationProvider configurationProvider,
        IMapper mapper)
    {
        this.repository = repository ?? throw new ArgumentException(null, nameof(repository));
        this.configurationProvider =
            configurationProvider ?? throw new ArgumentException(null, nameof(configurationProvider));
        this.mapper = mapper ?? throw new ArgumentException(null, nameof(mapper));
    }

    public async Task<IssueViews.IssueView> Handle(GetIssue message, CancellationToken cancellationToken)
    {
        var entity = await repository.GetById(message.Id, cancellationToken);

        return mapper.Map<IssueViews.IssueView>(entity);
    }

    public async Task<IReadOnlyList<IssueViews.IssueView>> Handle(GetIssues message, CancellationToken cancellationToken)
    {
        var result = await repository
            .Query()
            .ToListAsync(token: cancellationToken);

        return result.AsQueryable()
            .ProjectTo<IssueViews.IssueView>(configurationProvider)
            .ToList();
    }
}
using System;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using Backend.DDD.Sample.Contracts.Issues.Commands;
using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.Repositories;
using MediatR;

namespace Backend.DDD.Sample.Issues.Handlers
{
    internal class IssueCommandHandler
        : ICommandHandler<CreateIssue>
    {
        private readonly IRepository<Issue> repository;
        private readonly IMapper mapper;

        public IssueCommandHandler(
            IRepository<Issue> repository,
            IMapper mapper
        )
        {
            this.repository = repository ?? throw new ArgumentException(nameof(repository));
            this.mapper = mapper ?? throw new ArgumentException(nameof(mapper));
        }

        public async Task<Unit> Handle(CreateIssue message, CancellationToken cancellationToken)
        {
            var aggregate = mapper.Map<Issue>(message);

            await repository.AddAsync(aggregate);
            await repository.SaveChangesAsync();

            return Unit.Value;
        }
    }
}

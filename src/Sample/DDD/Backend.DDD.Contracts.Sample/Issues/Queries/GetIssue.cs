using System;
using GoldenEye.Backend.Core.DDD.Queries;

namespace Backend.DDD.Contracts.Sample.Issues.Queries
{
    public class GetIssue : IQuery<Issue>
    {
        public Guid Id { get; }

        public GetIssue(Guid id)
        {
            Id = id;
        }
    }
}
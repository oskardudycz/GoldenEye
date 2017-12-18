using System;
using GoldenEye.Backend.Core.DDD.Queries;

namespace Backend.DDD.Sample.Contracts.Issues.Queries
{
    public class GetIssue : IQuery<Views.Issue>
    {
        public Guid Id { get; }

        public GetIssue(Guid id)
        {
            Id = id;
        }
    }
}
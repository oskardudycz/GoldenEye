using System;
using Backend.DDD.Sample.Contracts.Issues.Views;
using GoldenEye.Backend.Core.DDD.Queries;

namespace Backend.DDD.Sample.Contracts.Issues.Queries
{
    public class GetIssue : IQuery<Views.IssueView>
    {
        public Guid Id { get; }

        public GetIssue(Guid id)
        {
            Id = id;
        }
    }
}
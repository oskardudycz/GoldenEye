using System;
using Backend.DDD.Sample.Contracts.Issues.Views;
using GoldenEye.DDD.Queries;

namespace Backend.DDD.Sample.Contracts.Issues.Queries
{
    public class GetIssue: IQuery<IssueView>
    {
        public GetIssue(Guid id)
        {
            Id = id;
        }

        public Guid Id { get; }
    }
}

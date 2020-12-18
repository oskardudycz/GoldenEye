using System;
using Backend.DDD.Sample.Contracts.Issues.Views;
using GoldenEye.Queries;

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

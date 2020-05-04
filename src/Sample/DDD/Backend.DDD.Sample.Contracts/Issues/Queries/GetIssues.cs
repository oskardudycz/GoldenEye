using Backend.DDD.Sample.Contracts.Issues.Views;
using GoldenEye.Backend.Core.DDD.Queries;

namespace Backend.DDD.Sample.Contracts.Issues.Queries
{
    public class GetIssues: IListQuery<IssueView>
    {
    }
}

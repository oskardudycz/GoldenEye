using Backend.DDD.Sample.Contracts.Issues.Views;
using GoldenEye.DDD.Queries;

namespace Backend.DDD.Sample.Contracts.Issues.Queries
{
    public class GetIssues: IListQuery<IssueView>
    {
    }
}

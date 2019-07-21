using GoldenEye.Backend.Core.DDD.Commands;

namespace Backend.DDD.Sample.Contracts.Issues.Commands
{
    public class CreateIssue: ICommand
    {
        public IssueType Type { get; }

        public string Title { get; }

        public string Description { get; }

        public CreateIssue(IssueType type, string title, string description)
        {
            Type = type;
            Title = title;
            Description = description;
        }
    }
}

using GoldenEye.DDD.Commands;

namespace Backend.DDD.Sample.Contracts.Issues.Commands
{
    public class CreateIssue: ICommand
    {
        public CreateIssue(IssueType type, string title, string description)
        {
            Type = type;
            Title = title;
            Description = description;
        }

        public IssueType Type { get; }

        public string Title { get; }

        public string Description { get; }
    }
}

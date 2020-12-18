using FluentValidation;
using GoldenEye.DDD.Commands;

namespace GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Commands
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

    public class CreateIssueValidator: AbstractValidator<CreateIssue>
    {
        public CreateIssueValidator()
        {
            RuleFor(r => r.Type).IsInEnum();
            RuleFor(r => r.Title).NotEmpty();
        }
    }
}

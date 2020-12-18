using System;
using FluentValidation;
using GoldenEye.Commands;

namespace GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Commands
{
    public class DeleteIssue: ICommand
    {
        public DeleteIssue(Guid id)
        {
            Id = id;
        }

        public Guid Id { get; }
    }

    public class DeleteIssueValidator: AbstractValidator<DeleteIssue>
    {
        public DeleteIssueValidator()
        {
            RuleFor(r => r.Id).NotEmpty();
        }
    }
}

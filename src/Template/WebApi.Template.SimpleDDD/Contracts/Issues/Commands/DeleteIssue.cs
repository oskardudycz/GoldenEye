using System;
using FluentValidation;
using GoldenEye.Backend.Core.DDD.Commands;

namespace Contracts.Issues.Commands
{
    public class DeleteIssue : ICommand
    {
        public Guid Id { get; }

        public DeleteIssue(Guid id)
        {
            Id = id;
        }
    }

    public class DeleteIssueValidator : AbstractValidator<DeleteIssue>
    {
        public DeleteIssueValidator()
        {
            RuleFor(r => r.Id).NotEmpty();
        }
    }
}
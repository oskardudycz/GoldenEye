using System;
using FluentValidation;
using GoldenEye.Backend.Core.DDD.Queries;

namespace GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Queries
{
    public class GetIssue: IQuery<Views.IssueView>
    {
        public Guid Id { get; }

        public GetIssue(Guid id)
        {
            Id = id;
        }
    }

    public class GetIssueValidator: AbstractValidator<GetIssue>
    {
        public GetIssueValidator()
        {
            RuleFor(r => r.Id).NotEmpty();
        }
    }
}

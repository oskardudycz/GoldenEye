using System;
using FluentValidation;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Views;

namespace GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Queries
{
    public class GetIssue: IQuery<IssueView>
    {
        public GetIssue(Guid id)
        {
            Id = id;
        }

        public Guid Id { get; }
    }

    public class GetIssueValidator: AbstractValidator<GetIssue>
    {
        public GetIssueValidator()
        {
            RuleFor(r => r.Id).NotEmpty();
        }
    }
}

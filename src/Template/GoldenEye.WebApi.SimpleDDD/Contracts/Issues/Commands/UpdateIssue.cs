using System;
using GoldenEye.Backend.Core.DDD.Commands;

namespace Contracts.Issues.Commands
{
    public class UpdateIssue : ICommand
    {
        public Guid Id { get; }

        public IssueType Type { get; }

        public string Title { get; }

        public string Description { get; }

        public UpdateIssue(Guid id, IssueType type, string title, string description)
        {
            Id = id;
            Type = type;
            Title = title;
            Description = description;
        }
    }
}
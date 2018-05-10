using System;
using GoldenEye.Backend.Core.DDD.Commands;

namespace Contracts.Issues.Commands
{
    public class UpdateIssue : ICommand
    { 
        public Guid Id { get;}

        public IssueType Type { get; }

        public string Title { get; }

        public string Description { get; }

        public UpdateIssue(IssueType type, string title, string description)
        {
            Type = type;
            Title = title;
            Description = description;
        }
    }
}
using System;

namespace Backend.DDD.Contracts.Sample.Issues
{
    public class Issue
    {
        public Guid Id { get; }

        public IssueType Type { get; }

        public string Title { get; }

        public string Description { get; }

        public Issue(Guid id, IssueType type, string title, string description)
        {
            Id = id;
            Type = type;
            Title = title;
            Description = description;
        }
    }
}
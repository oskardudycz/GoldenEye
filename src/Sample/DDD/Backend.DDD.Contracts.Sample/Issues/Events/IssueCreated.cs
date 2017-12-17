using System;

namespace Backend.DDD.Contracts.Sample.Issues.Events
{
    public class IssueCreated
    {
        public Guid Id { get; }

        public IssueType Type { get; }

        public string Title { get; }

        public string Description { get; }

        public IssueCreated(Guid id, IssueType type, string title, string description)
        {
            Id = id;
            Type = type;
            Title = title;
            Description = description;
        }
    }
}
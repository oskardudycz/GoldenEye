using System;
using GoldenEye.Events;

namespace Backend.DDD.Sample.Contracts.Issues.Events;

public class IssueCreated: IEvent
{
    public IssueCreated(Guid issueId, IssueType type, string title, string description)
    {
        IssueId = issueId;
        Type = type;
        Title = title;
        Description = description;
    }

    public Guid IssueId { get; }

    public IssueType Type { get; }

    public string Title { get; }

    public string Description { get; }

    public Guid StreamId => IssueId;
}
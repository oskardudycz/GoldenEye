using System;
using GoldenEye.Backend.Core.DDD.Events;

namespace Contracts.Issues.Events
{
    public class IssueDeleted : IEvent
    {
        public Guid IssueId { get; }

        public Guid StreamId => IssueId;

        public IssueDeleted(Guid issueId)
        {
            IssueId = issueId;
        }
    }
}
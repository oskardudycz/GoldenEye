using System;
using GoldenEye.Backend.Core.DDD.Events;

namespace GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Events
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
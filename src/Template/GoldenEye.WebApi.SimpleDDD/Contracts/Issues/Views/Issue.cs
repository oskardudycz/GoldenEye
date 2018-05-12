using System;
using Contracts.Issues.Events;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.Shared.Core.Objects.General;

namespace Contracts.Issues.Views
{
    public class IssueView : IView<Guid>
    {
        public Guid Id { get; set; }

        public IssueType Type { get; set; }

        public string Title { get; set; }

        public string Description { get; set; }

        object IHasId.Id => Id;

        public void Apply(IssueCreated @event)
        {
            Id = @event.IssueId;
            Type = @event.Type;
            Title = @event.Title;
            Description = @event.Description;
        }

        public void Apply(IssueUpdated @event)
        {
            Id = @event.IssueId;
            Type = @event.Type;
            Title = @event.Title;
            Description = @event.Description;
        }
    }
}
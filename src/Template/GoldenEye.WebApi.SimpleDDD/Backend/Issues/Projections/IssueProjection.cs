using System;
using Contracts.Issues;
using Contracts.Issues.Events;
using Contracts.Issues.Views;
using GoldenEye.Shared.Core.Objects.General;
using Marten.Events.Projections;

namespace Backend.Issues.Projections
{
    internal class IssueProjection : ViewProjection<IssueView, Guid>
    {
        public Guid Id { get; set; }

        public IssueType Type { get; private set; }

        public string Title { get; private set; }

        public string Description { get; private set; }

        public IssueProjection()
        {
            ProjectEvent<IssueCreated>(ev => ev.IssueId, (item, @event) => item.Apply(@event));
        }

        private void Apply(IssueView item, IssueCreated @event)
        {
            Id = @event.IssueId;
            Type = @event.Type;
            Title = @event.Title;
            Description = @event.Description;
        }
    }
}
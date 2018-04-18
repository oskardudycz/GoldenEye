using System;
using Contracts.Issues.Events;
using Contracts.Issues.Views;
using Marten.Events.Projections;

namespace Backend.Issues.Projections
{
    internal class IssueProjection : ViewProjection<IssueView, Guid>
    {
        public IssueProjection()
        {
            ProjectEvent<IssueCreated>(ev => ev.IssueId, (item, @event) => item.Apply(@event));
        }

        private void Apply(IssueView item, IssueCreated @event)
        {
        }
    }
}
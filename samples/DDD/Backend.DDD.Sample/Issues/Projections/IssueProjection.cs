using System;
using Backend.DDD.Sample.Contracts.Issues.Events;
using Backend.DDD.Sample.Contracts.Issues.Views;
using Marten.Events.Projections;

namespace Backend.DDD.Sample.Issues.Projections
{
    internal class IssueProjection: ViewProjection<IssueView, Guid>
    {
        public IssueProjection()
        {
            Identity<IssueCreated>(ev => ev.IssueId);
            ProjectEvent<IssueCreated>((item, @event) => item.Apply(@event));
        }

        private void Apply(IssueView item, IssueCreated @event)
        {
        }
    }
}

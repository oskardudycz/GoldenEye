﻿using System;
using Backend.DDD.Sample.Contracts.Issues.Events;
using Marten.Events.Projections;

namespace Backend.DDD.Sample.Issues.Projections
{
    internal class IssueProjection : ViewProjection<Contracts.Issues.Views.IssueView, Guid>
    {
        public IssueProjection()
        {
            ProjectEvent<IssueCreated>(ev => ev.IssueId, (item, @event) => item.Apply(@event));
        }

        private void Apply(Contracts.Issues.Views.IssueView item, IssueCreated @event)
        {
        }
    }
}
using GoldenEye.Backend.Core.DDD.Aggregates;
using System;
using System.Collections.Generic;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.DDD.Events
{
    public abstract class EventSource : IAggregate
    {
        public Guid Id { get; protected set; }
        object IHasObjectId.Id => Id;

        public Queue<IEvent> PendingEvents { get; }

        protected EventSource()
        {
            PendingEvents = new Queue<IEvent>();
        }

        protected void Append(IEvent @event)
        {
            PendingEvents.Enqueue(@event);
        }
    }
}
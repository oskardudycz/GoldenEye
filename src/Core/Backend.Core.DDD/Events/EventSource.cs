using System;
using System.Collections.Generic;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.DDD.Events
{
    public abstract class EventSource: IEventSource
    {
        public Guid Id { get; protected set; }
        object IHasId.Id => Id;

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

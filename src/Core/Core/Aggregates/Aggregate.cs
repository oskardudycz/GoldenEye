using System;
using System.Collections.Generic;
using GoldenEye.Events;
using GoldenEye.Objects.General;

namespace GoldenEye.Aggregates
{
    public abstract class Aggregate<TKey>: IAggregate<TKey>
    {
        public TKey Id { get; protected set; }

        object IHaveId.Id => Id;

        public int Version { get; protected set; }

        [NonSerialized] private readonly Queue<IEvent> uncommittedEvents = new Queue<IEvent>();

        //for serialization purposes
        protected Aggregate() { }

        public IEvent[] DequeueUncommittedEvents()
        {
            var dequeuedEvents = uncommittedEvents.ToArray();

            uncommittedEvents.Clear();

            return dequeuedEvents;
        }

        protected void Enqueue(IEvent @event)
        {
            uncommittedEvents.Enqueue(@event);
        }
    }

    public abstract class Aggregate: Aggregate<Guid>
    {

    }
}

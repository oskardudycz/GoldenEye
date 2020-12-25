using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Aggregates;
using GoldenEye.Extensions.Collections;

namespace GoldenEye.Events.Aggregate
{
    public class AggregateEventsPublisher: IAggregateEventsPublisher
    {
        private readonly IEventBus eventBus;
        private readonly Queue<IEvent> pendingEvents = new();

        public AggregateEventsPublisher(IEventBus eventBus)
        {
            this.eventBus = eventBus;
        }

        public IEvent[] EnqueueEventsFrom(IAggregate aggregate)
        {
            var uncomittedEvents = aggregate.DequeueUncommittedEvents();

            pendingEvents.EnqueueRange(uncomittedEvents);

            return uncomittedEvents;
        }

        public bool TryEnqueueEventsFrom(object entity, out IEvent[] uncomittedEvents)
        {
            if (!(entity is IAggregate aggregate))
            {
                uncomittedEvents = null;
                return false;
            }

            uncomittedEvents = EnqueueEventsFrom(aggregate);
            return true;
        }

        public Task Publish(CancellationToken cancellationToken = default)
        {
            var eventsToPublish = pendingEvents.ToArray();
            pendingEvents.Clear();

            return eventBus.Publish(cancellationToken, eventsToPublish);
        }
    }
}

using GoldenEye.Backend.Core.DDD.Events.Store;
using MediatR.Pipeline;
using System;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.DDD.Events.Logging
{
    public class EventStorePipeline<TEvent> : IRequestPreProcessor<TEvent> where TEvent : IEvent
    {
        private readonly IEventStore eventStore;

        public EventStorePipeline(IEventStore eventStore)
        {
            this.eventStore = eventStore ?? throw new ArgumentException(nameof(eventStore));
        }

        public async Task Process(TEvent @event)
        {
            await eventStore.StoreAsync(@event.StreamId, @event);
            await eventStore.SaveChangesAsync();
        }
    }
}

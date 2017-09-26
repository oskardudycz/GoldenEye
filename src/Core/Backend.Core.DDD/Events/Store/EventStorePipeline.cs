using GoldenEye.Backend.Core.DDD.Events.Store;
using MediatR.Pipeline;
using System;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.DDD.Events.Logging
{
    public class EventStorePipeline<TEvent> : IRequestPreProcessor<TEvent> 
    {
        private readonly IEventStore eventStore;

        public EventStorePipeline(IEventStore eventStore)
        {
            this.eventStore = eventStore ?? throw new ArgumentException(nameof(eventStore));
        }

        public async Task Process(TEvent request)
        {
            if (!(request is IEvent))
                return;

            var @event = (IEvent)request;

            await eventStore.StoreAsync(@event.StreamId, @event);
            await eventStore.SaveChangesAsync();
        }
    }
}

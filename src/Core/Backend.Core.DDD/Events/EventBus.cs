using System.Threading;
using System.Threading.Tasks;
using MediatR;

namespace GoldenEye.Backend.Core.DDD.Events
{
    public class EventBus : IEventBus
    {
        private readonly IMediator _mediator;

        public EventBus(IMediator mediator)
        {
            _mediator = mediator;
        }

        public Task PublishAsync<TEvent>(TEvent @event, CancellationToken cancellationToken = default(CancellationToken)) where TEvent : IEvent
        {
            return _mediator.Publish(@event, cancellationToken);
        }
    }
}
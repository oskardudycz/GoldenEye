using System.Threading;
using System.Threading.Tasks;
using MediatR;

namespace GoldenEye.Backend.Core.DDD.Commands
{
    public class CommandBus: ICommandBus
    {
        private readonly IMediator _mediator;

        public CommandBus(IMediator mediator)
        {
            _mediator = mediator;
        }

        public Task SendAsync<TCommand>(TCommand command, CancellationToken cancellationToken = default)
            where TCommand : ICommand
        {
            return _mediator.Send(command, cancellationToken);
        }
    }
}

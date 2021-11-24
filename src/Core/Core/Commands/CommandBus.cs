using System.Threading;
using System.Threading.Tasks;
using MediatR;

namespace GoldenEye.Commands;

public class CommandBus: ICommandBus
{
    private readonly IMediator _mediator;

    public CommandBus(IMediator mediator)
    {
        _mediator = mediator;
    }

    public Task Send<TCommand>(TCommand command, CancellationToken cancellationToken = default)
        where TCommand : ICommand
    {
        return _mediator.Send(command, cancellationToken);
    }
}
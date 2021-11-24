using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Commands;

public interface ICommandBus
{
    Task Send<TCommand>(TCommand command, CancellationToken cancellationToken = default)
        where TCommand : ICommand;
}
using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.DDD.Commands
{
    public interface ICommandBus
    {
        Task SendAsync<TCommand>(TCommand command, CancellationToken cancellationToken = default)
            where TCommand : ICommand;
    }
}

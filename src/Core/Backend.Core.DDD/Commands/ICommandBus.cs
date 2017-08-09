using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.DDD.Commands
{
    public interface ICommandBus
    {
        Task Send<TCommand>(TCommand command) where TCommand : ICommand;
    }
}

using MediatR;

namespace GoldenEye.Backend.Core.DDD.Commands
{
    public interface ICommandHandler<in T> : IRequestHandler<T>
        where T : ICommand
    {
    }
}
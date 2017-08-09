using MediatR;

namespace GoldenEye.Backend.Core.DDD.Commands
{
    public interface IAsyncCommandHandler<in T> : IAsyncRequestHandler<T>
        where T : ICommand
    {
    }
}

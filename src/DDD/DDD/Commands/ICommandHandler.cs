using MediatR;

namespace GoldenEye.DDD.Commands
{
    public interface ICommandHandler<in T>: IRequestHandler<T>
        where T : ICommand
    {
    }
}

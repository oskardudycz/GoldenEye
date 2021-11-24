using MediatR;

namespace GoldenEye.Commands;

public interface ICommandHandler<in T>: IRequestHandler<T>
    where T : ICommand
{
}
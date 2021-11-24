using MediatR;

namespace GoldenEye.Queries;

public interface IQuery<out TResponse>: IRequest<TResponse>
{
}
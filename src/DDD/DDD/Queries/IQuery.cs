using MediatR;

namespace GoldenEye.DDD.Queries
{
    public interface IQuery<out TResponse>: IRequest<TResponse>
    {
    }
}

using MediatR;

namespace GoldenEye.Backend.Core.DDD.Queries
{
    public interface IQuery<out TResponse> : IRequest<TResponse>
    {
    }
}

using MediatR;

namespace GoldenEye.Backend.Core.DDD.Queries
{
    public interface IAsyncQueryHandler<in TQuery, TResponse> : IAsyncRequestHandler<TQuery, TResponse>
           where TQuery : IQuery<TResponse>
    {
    }
}

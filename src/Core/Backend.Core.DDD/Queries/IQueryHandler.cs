using MediatR;

namespace GoldenEye.Backend.Core.DDD.Queries
{
    public interface IQueryHandler<in TQuery, out TResponse> : IRequestHandler<TQuery, TResponse>
           where TQuery : IQuery<TResponse>
    {
    }
}

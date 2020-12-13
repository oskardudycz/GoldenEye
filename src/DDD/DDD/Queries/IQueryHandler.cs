using MediatR;

namespace GoldenEye.DDD.Queries
{
    public interface IQueryHandler<in TQuery, TResponse>: IRequestHandler<TQuery, TResponse>
        where TQuery : IQuery<TResponse>
    {
    }
}

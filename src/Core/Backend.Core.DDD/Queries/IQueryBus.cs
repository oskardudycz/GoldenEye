using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.DDD.Queries
{
    public interface IQueryBus
    {
        Task<TResponse> SendAsync<TQuery, TResponse>(TQuery query, CancellationToken cancellationToken = default(CancellationToken)) where TQuery : IQuery<TResponse>;
    }
}
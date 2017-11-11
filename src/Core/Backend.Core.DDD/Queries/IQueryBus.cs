using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.DDD.Queries
{
    public interface IQueryBus
    {
        Task<TResponse> Send<TQuery, TResponse>(TQuery query) where TQuery : IQuery<TResponse>;
    }
}

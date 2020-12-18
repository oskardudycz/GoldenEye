using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Services
{
    public interface IReadonlyService<TDto> where TDto : class
    {
        IQueryable<TDto> Query();

        Task<TDto> GetAsync(object id, CancellationToken cancellationToken = default);
    }
}

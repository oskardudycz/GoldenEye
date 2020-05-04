using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.Services
{
    public interface ICRUDService<TDto>: IReadonlyService<TDto> where TDto : class
    {
        Task<bool> DeleteAsync(object id, CancellationToken cancellationToken = default);

        Task<TDto> AddAsync(TDto dto, CancellationToken cancellationToken = default);

        Task<TDto> UpdateAsync(object id, TDto dto, CancellationToken cancellationToken = default);
    }
}

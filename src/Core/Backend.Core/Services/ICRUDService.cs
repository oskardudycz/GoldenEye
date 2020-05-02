using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Backend.Core.Services
{
    public interface ICRUDService<TDto>: IReadonlyService<TDto> where TDto : class, IDTO
    {
        Task<bool> DeleteAsync(object id, CancellationToken cancellationToken = default);

        Task<TDto> AddAsync(TDto dto, CancellationToken cancellationToken = default);

        Task<TDto> UpdateAsync(TDto dto, CancellationToken cancellationToken = default);
    }
}

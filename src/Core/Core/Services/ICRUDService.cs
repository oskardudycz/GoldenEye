using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Services;

public interface ICRUDService<TDto>: IReadonlyService<TDto> where TDto : class
{
    Task<bool> Delete(object id, CancellationToken cancellationToken = default);

    Task<TDto> Add(TDto dto, CancellationToken cancellationToken = default);

    Task<TDto> Update(object id, TDto dto, CancellationToken cancellationToken = default);
}
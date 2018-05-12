using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Backend.Core.Services
{
    public interface IRestService<TDTO> : IReadonlyService<TDTO> where TDTO : class, IDTO
    {
        Task<bool> DeleteAsync(object id, CancellationToken cancellationToken = default(CancellationToken));

        Task<TDTO> PostAsync(TDTO dto, CancellationToken cancellationToken = default(CancellationToken));

        Task<TDTO> PutAsync(TDTO dto, CancellationToken cancellationToken = default(CancellationToken));
    }
}
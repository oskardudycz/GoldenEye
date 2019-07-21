using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Backend.Core.Services
{
    public interface IReadonlyService<TDTO>: IDisposable where TDTO : class, IDTO
    {
        IQueryable<TDTO> Get();

        Task<TDTO> GetAsync(int id, CancellationToken cancellationToken = default(CancellationToken));
    }
}

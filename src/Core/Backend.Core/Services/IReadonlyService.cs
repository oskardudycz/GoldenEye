using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Backend.Core.Services
{
    public interface IReadonlyService<TDto> where TDto : class, IDTO
    {
        IQueryable<TDto> Query();

        Task<TDto> GetAsync(int id, CancellationToken cancellationToken = default);
    }
}

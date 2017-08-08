using System.Linq;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.DTO;
using System;

namespace GoldenEye.Backend.Core.Service
{
    public interface IReadonlyService<TDTO> : IDisposable where TDTO : class, IDTO
    {
        IQueryable<TDTO> Get();
        Task<TDTO> Get(int id);
    }
}
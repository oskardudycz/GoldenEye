using System.Linq;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.DTOs;

namespace GoldenEye.Shared.Core.Services
{
    public interface IReadonlyRestService<TDTO> : IService where TDTO : IDTO
    {
        IQueryable<TDTO> Get();
        Task<TDTO> Get(int id);
    }
}
using System.Linq;
using System.Threading.Tasks;
using Shared.Core.DTOs;

namespace Backend.Core.Service
{
    public interface IReadonlyRestService<TDTO> : IService where TDTO : IDTO
    {
        IQueryable<TDTO> Get();
        Task<TDTO> Get(int id);
    }
}
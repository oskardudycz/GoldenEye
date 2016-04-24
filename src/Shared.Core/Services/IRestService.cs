using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Shared.Core.Services
{
    public interface IRestService<TDTO> : IReadonlyRestService<TDTO> where TDTO : IDTO
    {
        Task<TDTO> Put(TDTO dto);

        Task<TDTO> Post(TDTO dto);

        Task<bool> Delete(int id);
    }
}

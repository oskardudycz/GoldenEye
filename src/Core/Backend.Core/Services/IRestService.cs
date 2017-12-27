using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Backend.Core.Services
{
    public interface IRestService<TDTO> : IReadonlyService<TDTO> where TDTO : class, IDTO
    {
        Task<bool> Delete(int id);

        Task<TDTO> Post(TDTO dto);

        Task<TDTO> Put(TDTO dto);
    }
}
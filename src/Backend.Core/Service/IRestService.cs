using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.DTO;
using System;

namespace GoldenEye.Backend.Core.Service
{
    public interface IRestService<TDTO> : IDisposable where TDTO : class, IDTO
    {
        Task<bool> Delete(int id);
        Task<TDTO> Post(TDTO dto);
        Task<TDTO> Put(TDTO dto);
    }
}
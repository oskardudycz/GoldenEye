using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Shared.Core.DTOs;

namespace Backend.Core.Service
{
    public interface IRestService<TDTO> : IReadonlyRestService<TDTO> where TDTO : IDTO
    {
        Task<TDTO> Put(TDTO dto);

        Task<TDTO> Post(TDTO dto);

        Task<bool> Delete(int id);
    }
}

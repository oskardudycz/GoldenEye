using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Shared.Core.DTOs;

namespace Backend.Core.Service
{
    public interface IRestService<TDTO> : IService
        where TDTO : IDTO
    {
        IQueryable<TDTO> Get();

        Task<TDTO> Get(int id);

        Task<TDTO> Put(TDTO dto);

        Task<TDTO> Post(TDTO dto);

        Task<bool> Delete(int id);
    }
}

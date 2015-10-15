using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Shared.Core;
using Shared.Core.Contracts;

namespace Backend.Core.Service
{
    public interface IServiceBase<TContract> : IService
        where TContract : IBaseContract
    {
        TContract GetById(int id);

        IQueryable<TContract> GetAll();

        TContract Add(TContract contract);

        IQueryable<TContract> AddAll(IQueryable<TContract> contracts);

        TContract Update(TContract contract);

        bool Remove(int id);
    }
}

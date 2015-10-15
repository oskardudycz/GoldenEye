using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Threading.Tasks;
using Shared.Core.DTOs;

namespace Backend.Core.Service
{
    public class RestServiceBase<TDTO> : ServiceBase, IRestService<TDTO> where TDTO : IDTO
    {
        public virtual IQueryable<TDTO> Get()
        {
            throw new NotImplementedException();
        }

        public virtual Task<TDTO> Get(int id)
        {
            throw new NotImplementedException();
        }

        public virtual Task<TDTO> Put(TDTO dto)
        {
            throw new NotImplementedException();
        }

        public virtual Task<TDTO> Post(TDTO dto)
        {
            throw new NotImplementedException();
        }

        public virtual Task<bool> Delete(int id)
        {
            throw new NotImplementedException();
        }
        protected override void OnDispose()
        {

        }
    }
}
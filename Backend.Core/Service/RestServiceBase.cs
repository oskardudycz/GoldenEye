using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Threading.Tasks;
using Shared.Core.DTOs;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using System.Threading.Tasks;
using Shared.Business.Contracts;
using Shared.Core.Contracts;

namespace Backend.Core.Service
{
    public class RestServiceBase<TDTO, TContract> : ServiceBase, IRestService<TDTO> 
        where TDTO : IDTO
        where TContract : IBaseContract
    {
        private readonly IBaseService<TContract> _service;

        protected RestServiceBase(IBaseService<TContract> service)
        {
            _service = service;
        }

        public virtual IQueryable<TDTO> Get()
        {
            return _service.GetAll().ProjectTo<TDTO>(); 
        }

        public virtual Task<TDTO> Get(int id)
        {
            return Task.Run(() => Mapper.Map<TContract, TDTO>(_service.GetById(id)));
        }

        public virtual Task<TDTO> Put(TDTO dto)
        {
            return Task.Run(() =>
                Mapper.Map<TContract, TDTO>(
                    _service.Add(Mapper.Map<TDTO, TContract>(dto))));
        }

        public virtual Task<TDTO> Post(TDTO dto)
        {
            return Task.Run(() =>
                Mapper.Map<TContract, TDTO>(
                    _service.Update(Mapper.Map<TDTO, TContract>(dto))));
        }

        public virtual Task<bool> Delete(int id)
        {
            return Task.Run(() => _service.Remove(id));
        }
        protected override void OnDispose()
        {

        }
    }
}
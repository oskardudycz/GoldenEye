using System;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Backend.Core.Entity;
using Backend.Core.Repository;
using Shared.Core.DTOs;

namespace Backend.Core.Service
{
    public abstract class ReadonlyRestServiceBase<TDTO, TEntity> : IReadonlyRestService<TDTO> where TDTO : class, IDTO where TEntity : class, IEntity
    {
        private bool _disposed;
        protected IReadonlyRepository<TEntity> Repository;

        protected ReadonlyRestServiceBase(IReadonlyRepository<TEntity> repository)
        {
            Repository = repository;
        }

        public virtual IQueryable<TDTO> Get()
        {
            return Repository.GetAll().ProjectTo<TDTO>();
        }

        public virtual Task<TDTO> Get(int id)
        {
            return Task.Run(() => Mapper.Map<TEntity, TDTO>(Repository.GetById(id)));
        }

        public virtual void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        private void Dispose(bool disposing)
        {
            if (_disposed) return;

            if (disposing)
            {
                Repository.Dispose();
            }

            _disposed = true;
        }
    }
}
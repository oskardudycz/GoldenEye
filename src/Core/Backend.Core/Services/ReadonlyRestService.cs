using System;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Backend.Core.Services
{
    public class ReadonlyRestService<TDTO, TEntity, TRepository> : ReadonlyRestService<TDTO, TEntity>
        where TDTO : class, IDTO
        where TEntity : class, IEntity
        where TRepository : IReadonlyRepository<TEntity>
    {
        protected ReadonlyRestService(TRepository repository) : base(repository)
        {
        }
    }

    public class ReadonlyRestService<TDTO, TEntity> : IReadonlyService<TDTO> where TDTO : class, IDTO where TEntity : class, IEntity
    {
        private bool _disposed;
        protected IReadonlyRepository<TEntity> Repository;

        protected ReadonlyRestService(IReadonlyRepository<TEntity> repository)
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
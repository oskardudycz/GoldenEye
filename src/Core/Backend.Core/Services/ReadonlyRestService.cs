using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Extensions.Mapping;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Backend.Core.Services
{
    public class ReadonlyRestService<TDTO, TEntity, TRepository> : ReadonlyRestService<TDTO, TEntity>
        where TDTO : class, IDTO
        where TEntity : class, IEntity
        where TRepository : IReadonlyRepository<TEntity>
    {
        protected ReadonlyRestService(
            TRepository repository,
            IConfigurationProvider configurationProvider) : base(repository, configurationProvider)
        {
        }
    }

    public class ReadonlyRestService<TDTO, TEntity> : IReadonlyService<TDTO> where TDTO : class, IDTO where TEntity : class, IEntity
    {
        private bool _disposed;
        protected IReadonlyRepository<TEntity> Repository;
        protected readonly IConfigurationProvider ConfigurationProvider;

        protected ReadonlyRestService(
            IReadonlyRepository<TEntity> repository,
            IConfigurationProvider configurationProvider)
        {
            Repository = repository;
            this.ConfigurationProvider = configurationProvider;
        }

        public virtual IQueryable<TDTO> Get()
        {
            return Repository.GetAll().ProjectTo<TDTO>(ConfigurationProvider);
        }

        public virtual async Task<TDTO> GetAsync(int id, CancellationToken cancellationToken = default(CancellationToken))
        {
            return (await Repository.GetByIdAsync(id, cancellationToken)).MapTo<TDTO>();
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
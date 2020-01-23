using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Backend.Core.Services
{
    public class ReadonlyRestService<TDTO, TEntity, TRepository>: ReadonlyRestService<TDTO, TEntity>
        where TDTO : class, IDTO
        where TEntity : class, IEntity
        where TRepository : IReadonlyRepository<TEntity>
    {
        protected ReadonlyRestService(
            TRepository repository,
            IMapper mapper
        ) : base(repository, mapper)
        {
        }
    }

    public class ReadonlyRestService<TDTO, TEntity>: IReadonlyService<TDTO> where TDTO : class, IDTO where TEntity : class, IEntity
    {
        private bool _disposed;
        protected IReadonlyRepository<TEntity> Repository;
        protected readonly IMapper Mapper;
        protected IConfigurationProvider ConfigurationProvider => Mapper.ConfigurationProvider;

        protected ReadonlyRestService(
            IReadonlyRepository<TEntity> repository,
            IMapper mapper
        )
        {
            Repository = repository;
            Mapper = mapper;
        }

        public virtual IQueryable<TDTO> Get()
        {
            return Repository.GetAll().ProjectTo<TDTO>(ConfigurationProvider);
        }

        public virtual async Task<TDTO> GetAsync(int id, CancellationToken cancellationToken = default(CancellationToken))
        {
            var entity = await Repository.GetByIdAsync(id, cancellationToken);
            return Mapper.Map<TDTO>(entity);
        }

        public virtual void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        private void Dispose(bool disposing)
        {
            if (_disposed)
                return;

            if (disposing)
            {
                Repository.Dispose();
            }

            _disposed = true;
        }
    }
}

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

    public class ReadonlyRestService<TDto, TEntity>: IReadonlyService<TDto> where TDto : class, IDTO where TEntity : class, IEntity
    {
        protected readonly IReadonlyRepository<TEntity> Repository;
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

        public virtual IQueryable<TDto> Query()
        {
            return Repository.GetAll().ProjectTo<TDto>(ConfigurationProvider);
        }

        public virtual async Task<TDto> GetAsync(int id, CancellationToken cancellationToken = default)
        {
            var entity = await Repository.GetByIdAsync(id, cancellationToken);
            return Mapper.Map<TDto>(entity);
        }
    }
}

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
    public class ReadonlyService<TDTO, TEntity, TRepository>: ReadonlyService<TDTO, TEntity>
        where TDTO : class, IDTO
        where TEntity : class, IEntity
        where TRepository : IReadonlyRepository<TEntity>
    {
        protected ReadonlyService(
            TRepository repository,
            IMapper mapper
        ) : base(repository, mapper)
        {
        }
    }

    public class ReadonlyService<TDto, TEntity>: IReadonlyService<TDto> where TDto : class, IDTO where TEntity : class, IEntity
    {
        protected readonly IReadonlyRepository<TEntity> Repository;
        protected readonly IMapper Mapper;
        protected IConfigurationProvider ConfigurationProvider => Mapper.ConfigurationProvider;

        protected ReadonlyService(
            IReadonlyRepository<TEntity> repository,
            IMapper mapper
        )
        {
            Repository = repository;
            Mapper = mapper;
        }

        public virtual IQueryable<TDto> Query()
        {
            return Repository.Query().ProjectTo<TDto>(ConfigurationProvider);
        }

        public virtual async Task<TDto> GetAsync(int id, CancellationToken cancellationToken = default)
        {
            var entity = await Repository.GetByIdAsync(id);
            return Mapper.Map<TDto>(entity);
        }
    }
}

using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using GoldenEye.Entities;
using GoldenEye.Repositories;

namespace GoldenEye.Services
{
    public class ReadonlyService<TDto, TEntity, TRepository>: ReadonlyService<TDto, TEntity>
        where TDto : class
        where TEntity : class, IEntity
        where TRepository : IReadonlyRepository<TEntity>
    {
        protected ReadonlyService(
            TRepository repository,
            IMapper mapper
        ): base(repository, mapper)
        {
        }
    }

    public class ReadonlyService<TDto, TEntity>: IReadonlyService<TDto>
        where TDto : class where TEntity : class, IEntity
    {
        protected readonly IMapper Mapper;
        protected readonly IReadonlyRepository<TEntity> Repository;

        protected ReadonlyService(
            IReadonlyRepository<TEntity> repository,
            IMapper mapper
        )
        {
            Repository = repository;
            Mapper = mapper;
        }

        protected IConfigurationProvider ConfigurationProvider => Mapper.ConfigurationProvider;

        public virtual IQueryable<TDto> Query()
        {
            return Repository.Query().ProjectTo<TDto>(ConfigurationProvider);
        }

        public virtual async Task<TDto> GetAsync(object id, CancellationToken cancellationToken = default)
        {
            var entity = await Repository.GetByIdAsync(id, cancellationToken);
            return Mapper.Map<TDto>(entity);
        }
    }
}

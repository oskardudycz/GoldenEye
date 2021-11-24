using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using GoldenEye.Entities;
using GoldenEye.Repositories;

namespace GoldenEye.Services;

public class ReadonlyService<TDto, TEntity, TRepository>: ReadonlyService<TDto, TEntity>
    where TDto : class
    where TEntity : class, IEntity
    where TRepository : IReadonlyRepository<TEntity>
{
    protected ReadonlyService(
        TRepository readonlyRepository,
        IMapper mapper
    ): base(readonlyRepository, mapper)
    {
    }
}

public class ReadonlyService<TDto, TEntity>: IReadonlyService<TDto>
    where TDto : class where TEntity : class, IEntity
{
    protected readonly IMapper Mapper;
    protected readonly IReadonlyRepository<TEntity> ReadonlyRepository;

    protected ReadonlyService(
        IReadonlyRepository<TEntity> readonlyRepository,
        IMapper mapper
    )
    {
        ReadonlyRepository = readonlyRepository;
        Mapper = mapper;
    }

    protected IConfigurationProvider ConfigurationProvider => Mapper.ConfigurationProvider;

    public virtual IQueryable<TDto> Query()
    {
        return ReadonlyRepository.Query().ProjectTo<TDto>(ConfigurationProvider);
    }

    public virtual async Task<TDto> Get(object id, CancellationToken cancellationToken = default)
    {
        var entity = await ReadonlyRepository.GetById(id, cancellationToken);
        return Mapper.Map<TDto>(entity);
    }
}
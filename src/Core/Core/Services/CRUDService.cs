using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using FluentValidation;
using GoldenEye.Entities;
using GoldenEye.Repositories;

namespace GoldenEye.Services;

public class CRUDService<TDto, TEntity, TRepository, TReadonlyRepository>: CRUDService<TDto, TEntity>
    where TDto : class
    where TEntity : class, IEntity
    where TRepository : IRepository<TEntity>
    where TReadonlyRepository: IReadonlyRepository<TEntity>
{
    protected CRUDService(
        TRepository repository,
        TReadonlyRepository readonlyRepository,
        IMapper mapper
    ): base(repository, readonlyRepository, mapper)
    {
    }

    protected new TRepository Repository
    {
        get { return (TRepository)base.Repository; }
    }
}

public class CRUDService<TDto, TEntity>: ReadonlyService<TDto, TEntity>, ICRUDService<TDto>
    where TDto : class
    where TEntity : class, IEntity
{
    protected readonly IValidator<TDto> DtoValidator;
    protected readonly IValidator<TEntity> EntityValidator;
    protected readonly IRepository<TEntity> Repository;

    protected CRUDService(
        IRepository<TEntity> repository,
        IReadonlyRepository<TEntity> readonlyRepository,
        IMapper mapper,
        IValidator<TDto> dtoValidator = null,
        IValidator<TEntity> entityValidator = null
    ): base(readonlyRepository, mapper)
    {
        Repository = repository;
        DtoValidator = dtoValidator;
        EntityValidator = entityValidator;
    }

    public virtual async Task<TDto> Add(TDto dto, CancellationToken cancellationToken = default)
    {
        await ValidateAsync(dto, cancellationToken);

        var entity = Mapper.Map<TEntity>(dto);

        await ValidateAsync(entity, cancellationToken);

        var added = Repository.Add(entity, cancellationToken);

        await Repository.SaveChanges(cancellationToken);

        return Mapper.Map<TDto>(added);
    }

    public virtual async Task<TDto> Update(object id, TDto dto, CancellationToken cancellationToken = default)
    {
        await ValidateAsync(dto, cancellationToken);

        var fromDb = await Repository.GetById(id, cancellationToken);

        var entity = Mapper.Map(dto, fromDb);

        await ValidateAsync(entity, cancellationToken);

        var updated = await Repository.Update(entity, cancellationToken);

        await Repository.SaveChanges(cancellationToken);

        return Mapper.Map<TDto>(updated);
    }

    public virtual Task<bool> Delete(object id, CancellationToken cancellationToken = default)
    {
        return Repository.DeleteById(id, cancellationToken);
    }

    private async Task ValidateAsync(TDto dto, CancellationToken cancellationToken)
    {
        await (DtoValidator?.ValidateAsync(dto, null, cancellationToken) ?? Task.CompletedTask);
    }

    private async Task ValidateAsync(TEntity entity, CancellationToken cancellationToken)
    {
        await (EntityValidator?.ValidateAsync(entity, null, cancellationToken) ?? Task.CompletedTask);
    }
}
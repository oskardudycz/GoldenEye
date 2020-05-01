using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using FluentValidation;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Backend.Core.Services
{
    public class RestService<TDto, TEntity, TRepository>: RestService<TDto, TEntity>
        where TDto : class, IDTO
        where TEntity : class, IEntity
        where TRepository : IRepository<TEntity>
    {
        protected new TRepository Repository
        {
            get { return (TRepository)base.Repository; }
        }

        protected RestService(
            TRepository repository,
            IMapper mapper) : base(repository, mapper)
        {
        }
    }

    public class RestService<TDto, TEntity>: ReadonlyRestService<TDto, TEntity>, IRestService<TDto>
        where TDto : class, IDTO
        where TEntity : class, IEntity
    {
        protected new IRepository<TEntity> Repository
        {
            get { return (IRepository<TEntity>)base.Repository; }
        }

        protected RestService(
            IRepository<TEntity> repository,
            IMapper mapper
        ) : base(repository, mapper)
        {
        }

        public virtual async Task<TDto> AddAsync(TDto dto, CancellationToken cancellationToken = default)
        {
            if (!Validate(dto))
                return null as TDto;

            var entity = Mapper.Map<TEntity>(dto);
            var added = Repository.AddAsync(entity, cancellationToken: cancellationToken);

            await Repository.SaveChangesAsync(cancellationToken);

            var fromDb = await Repository.GetByIdAsync(added.Id, cancellationToken);

            return Mapper.Map<TDto>(fromDb);
        }

        public virtual async Task<TDto> UpdateAsync(TDto dto, CancellationToken cancellationToken = default)
        {
            if (!Validate(dto))
                return null as TDto;

            var entity = Mapper.Map<TEntity>(dto);
            var updated = await Repository.UpdateAsync(entity, cancellationToken: cancellationToken);

            await Repository.SaveChangesAsync(cancellationToken);

            var fromDb = await Repository.GetByIdAsync(updated.Id, cancellationToken);

            return Mapper.Map<TDto>(fromDb);
        }

        public virtual Task<bool> DeleteAsync(object id, CancellationToken cancellationToken = default)
        {
            return Repository.DeleteAsync(id, cancellationToken);
        }

        protected virtual AbstractValidator<TDto> GetValidator()
        {
            return null;
        }

        protected bool Validate(TDto dto)
        {
            var validator = GetValidator();

            if (validator == null)
                return true;

            var results = validator.Validate(dto);

            return results.IsValid;
        }
    }
}

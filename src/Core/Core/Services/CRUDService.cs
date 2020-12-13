using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using FluentValidation;
using GoldenEye.Core.Entity;
using GoldenEye.Core.Repositories;

namespace GoldenEye.Core.Services
{
    public class CRUDService<TDto, TEntity, TRepository>: CRUDService<TDto, TEntity>
        where TDto : class
        where TEntity : class, IEntity
        where TRepository : IRepository<TEntity>
    {
        protected CRUDService(
            TRepository repository,
            IMapper mapper): base(repository, mapper)
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

        protected CRUDService(
            IRepository<TEntity> repository,
            IMapper mapper,
            IValidator<TDto> dtoValidator = null,
            IValidator<TEntity> entityValidator = null
        ): base(repository, mapper)
        {
            DtoValidator = dtoValidator;
            EntityValidator = entityValidator;
        }

        protected new IRepository<TEntity> Repository
        {
            get { return (IRepository<TEntity>)base.Repository; }
        }

        public virtual async Task<TDto> AddAsync(TDto dto, CancellationToken cancellationToken = default)
        {
            await ValidateAsync(dto, cancellationToken);

            var entity = Mapper.Map<TEntity>(dto);

            await ValidateAsync(entity, cancellationToken);

            var added = Repository.AddAsync(entity, cancellationToken);

            await Repository.SaveChangesAsync(cancellationToken);

            return Mapper.Map<TDto>(added);
        }

        public virtual async Task<TDto> UpdateAsync(object id, TDto dto, CancellationToken cancellationToken = default)
        {
            await ValidateAsync(dto, cancellationToken);

            var fromDb = await Repository.GetByIdAsync(id, cancellationToken);

            var entity = Mapper.Map(dto, fromDb);

            await ValidateAsync(entity, cancellationToken);

            var updated = await Repository.UpdateAsync(entity, cancellationToken);

            await Repository.SaveChangesAsync(cancellationToken);

            return Mapper.Map<TDto>(updated);
        }

        public virtual Task<bool> DeleteAsync(object id, CancellationToken cancellationToken = default)
        {
            return Repository.DeleteByIdAsync(id, cancellationToken);
        }

        private async Task ValidateAsync(TDto dto, CancellationToken cancellationToken)
        {
            await DtoValidator?.ValidateAsync(dto, null, cancellationToken);
        }

        private async Task ValidateAsync(TEntity entity, CancellationToken cancellationToken)
        {
            await EntityValidator?.ValidateAsync(entity, null, cancellationToken);
        }
    }
}

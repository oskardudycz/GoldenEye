using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using FluentValidation;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Backend.Core.Services
{
    public class RestService<TDTO, TEntity, TRepository>: RestService<TDTO, TEntity>
        where TDTO : class, IDTO
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

    public class RestService<TDTO, TEntity>: ReadonlyRestService<TDTO, TEntity>
        where TDTO : class, IDTO
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

        public virtual async Task<TDTO> PutAsync(TDTO dto, CancellationToken cancellationToken = default(CancellationToken))
        {
            if (!Validate(dto))
                return null as TDTO;

            var entity = Mapper.Map<TEntity>(dto);
            var added = Repository.AddAsync(entity, cancellationToken: cancellationToken);

            await Repository.SaveChangesAsync(cancellationToken);

            var fromDb = await Repository.GetByIdAsync(added.Id, cancellationToken);

            return Mapper.Map<TDTO>(fromDb);
        }

        public virtual async Task<TDTO> PostAsync(TDTO dto, CancellationToken cancellationToken = default(CancellationToken))
        {
            if (!Validate(dto))
                return null as TDTO;

            var entity = Mapper.Map<TEntity>(dto);
            var updated = await Repository.UpdateAsync(entity, cancellationToken: cancellationToken);

            await Repository.SaveChangesAsync(cancellationToken);

            var fromDb = await Repository.GetByIdAsync(updated.Id, cancellationToken);

            return Mapper.Map<TDTO>(fromDb);
        }

        public virtual Task<bool> Delete(int id)
        {
            return Task.Run(() => Repository.Delete(id));
        }

        protected virtual AbstractValidator<TDTO> GetValidator()
        {
            return null;
        }

        protected bool Validate(TDTO dto)
        {
            var validator = GetValidator();

            if (validator == null)
                return true;

            var results = validator.Validate(dto);

            return results.IsValid;
        }
    }
}

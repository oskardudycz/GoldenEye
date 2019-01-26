using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using FluentValidation;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Extensions.Mapping;
using GoldenEye.Shared.Core.Objects.DTO;

namespace GoldenEye.Backend.Core.Services
{
    public class RestService<TDTO, TEntity, TRepository> : RestService<TDTO, TEntity>
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
            IConfigurationProvider configurationProvider) : base(repository, configurationProvider)
        {
        }
    }

    public class RestService<TDTO, TEntity> : ReadonlyRestService<TDTO, TEntity>
        where TDTO : class, IDTO
        where TEntity : class, IEntity
    {
        protected new IRepository<TEntity> Repository
        {
            get { return (IRepository<TEntity>)base.Repository; }
        }

        protected RestService(
            IRepository<TEntity> repository,
            IConfigurationProvider configurationProvider) : base(repository, configurationProvider)
        {
        }

        public virtual async Task<TDTO> PutAsync(TDTO dto, CancellationToken cancellationToken = default(CancellationToken))
        {
            if (!Validate(dto))
                return null as TDTO;

            var entity = dto.MapTo<TEntity>();
            var added = Repository.AddAsync(entity, cancellationToken: cancellationToken);

            await Repository.SaveChangesAsync(cancellationToken);

            return (await Repository.GetByIdAsync(added.Id, cancellationToken)).MapTo<TDTO>();
        }

        public virtual async Task<TDTO> PostAsync(TDTO dto, CancellationToken cancellationToken = default(CancellationToken))
        {
            if (!Validate(dto))
                return null as TDTO;

            var entity = dto.MapTo<TEntity>();
            var updated = await Repository.UpdateAsync(entity, cancellationToken: cancellationToken);

            await Repository.SaveChangesAsync(cancellationToken);

            return (await Repository.GetByIdAsync(updated.Id, cancellationToken)).MapTo<TDTO>();
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
using System.Threading.Tasks;
using AutoMapper;
using FluentValidation;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Core.Repository;
using GoldenEye.Shared.Core.DTOs;

namespace GoldenEye.Backend.Core.Service
{
    public abstract class RestServiceBase<TDTO, TEntity, TRepository> : RestServiceBase<TDTO, TEntity>
        where TDTO : class, IDTO
        where TEntity : class, IEntity
        where TRepository : IRepository<TEntity>
    {
        protected new TRepository Repository
        {
            get { return (TRepository)base.Repository; }
        }

        protected RestServiceBase(TRepository repository) : base(repository)
        {
        }
    }

    public abstract class RestServiceBase<TDTO, TEntity> : ReadonlyRestServiceBase<TDTO, TEntity> 
        where TDTO : class, IDTO
        where TEntity : class, IEntity
    {
        protected new IRepository<TEntity> Repository
        {
            get { return (IRepository<TEntity>) base.Repository; }
        }

        protected RestServiceBase(IRepository<TEntity> repository) : base(repository)
        {
        }

        public virtual Task<TDTO> Put(TDTO dto)
        {
            if (!Validate(dto))
                return Task.Run(() => null as TDTO);

            var entity = Mapper.Map<TDTO, TEntity>(dto);
            var added = Repository.Add(entity);

            Repository.SaveChanges();

            return Task.Run(() =>
                Mapper.Map<TEntity, TDTO>(Repository.GetById(added.Id)));
        }

        public virtual Task<TDTO> Post(TDTO dto)
        {
            if (!Validate(dto))
                return Task.Run(() => null as TDTO);

            var entity = Mapper.Map<TDTO, TEntity>(dto);
            var updated = Repository.Update(entity);

            Repository.SaveChanges();
            return Task.Run(() =>
                Mapper.Map<TEntity, TDTO>(Repository.GetById(updated.Id)));
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
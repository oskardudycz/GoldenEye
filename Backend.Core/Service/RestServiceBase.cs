using System.Threading.Tasks;
using Shared.Core.DTOs;
using AutoMapper;
using Backend.Core.Repository;
using Backend.Core.Entity;
using FluentValidation;

namespace Backend.Core.Service
{
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

            return !results.IsValid;
        }
    }
}
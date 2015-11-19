using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Threading.Tasks;
using Shared.Core.DTOs;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Backend.Core.Repository;
using Backend.Core.Entity;
using Shared.Business.Validators;
using FluentValidation;

namespace Backend.Core.Service
{
    public abstract class RestServiceBase<TDTO, TEntity> : IRestService<TDTO> 
        where TDTO : class, IDTO
        where TEntity : class, IEntity
    {
        private bool _disposed;

        protected readonly IRepository<TEntity> Repository;

        protected RestServiceBase(IRepository<TEntity> repository)
        {
            Repository = repository;
        }

        public virtual IQueryable<TDTO> Get()
        {
            return Repository.GetAll().ProjectTo<TDTO>();
        }

        public virtual Task<TDTO> Get(int id)
        {
            return Task.Run(() => Mapper.Map<TEntity, TDTO>(Repository.GetById(id)));
        }

        public virtual Task<TDTO> Put(TDTO dto)
        {
            if (!Validation(dto))
                return Task.Run(() => null as TDTO);

            var entity = Mapper.Map<TDTO, TEntity>(dto);
            var added = Repository.Add(entity);

            Repository.SaveChanges();

            return Task.Run(() =>
                Mapper.Map<TEntity, TDTO>(Repository.GetById(added.Id)));
        }

        public virtual Task<TDTO> Post(TDTO dto)
        {
            if (!Validation(dto))
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

        protected abstract AbstractValidator<TDTO> GetValidator();

        protected bool Validation(TDTO dto)
        {
            var validator = GetValidator();
            var results = validator.Validate(dto);

            return !results.IsValid;
        }

        public virtual void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
        private void Dispose(bool disposing)
        {
            if (_disposed) return;

            if (disposing)
            {
                Repository.Dispose();
            }

            _disposed = true;
        }
    }
}
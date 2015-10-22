using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Backend.Core.Repository;
using Shared.Core;
using Backend.Core.Entity;
using Shared.Core.Contracts;

namespace Backend.Core.Service
{
    public abstract class BaseService<TEntity, TContract> : IBaseService<TContract>
        where TContract : class, IBaseContract
        where TEntity : class, IEntity
    {
        protected readonly IRepository<TEntity> Repository;

        protected BaseService(IRepository<TEntity> repository)
        {
            Repository = repository;
        }


        public TContract GetById(int id)
        {
            return Mapper.Map<TEntity, TContract>(Repository.GetById(id));
        }

        public virtual IQueryable<TContract> GetAll()
        {
            return Repository.GetAll().ProjectTo<TContract>();
        }
        /*
        public IQueryable<TContract> GetAllPaged(int page = 1, int numberOfItemsOnPage = 20)
        {
            return Mapper.Map<IQueryable<TEntity>, IQueryable<TContract>>(Repository.GetAllPaged(page, numberOfItemsOnPage));
        }*/
        public TContract Add(TContract contract)
        {
            Mapper.CreateMap<TContract, TEntity>();
            var entity = Mapper.Map<TContract, TEntity>(contract);
            /*
            if (!contract.Validate().IsValid)
            {
                throw new Exception(contract.Validate().ToString());
            }
            */
            var added = Repository.Add(entity);

            Repository.SaveChanges();
            return Mapper.Map<TEntity, TContract>(Repository.GetById(added.Id));
        }

        public IQueryable<TContract> AddAll(IQueryable<TContract> contracts)
        {
            var addedContracts = Repository.AddAll(Mapper.Map<IQueryable<TContract>, IQueryable<TEntity>>(contracts));
            Repository.SaveChanges();
            return Mapper.Map<IQueryable<TEntity>, IQueryable<TContract>>(addedContracts);
        }

        public TContract Update(TContract contract)
        {
            var entity = Mapper.Map<TContract, TEntity>(contract);
            /*
            if (!contract.Validate().IsValid)
            {
                throw new Exception(contract.Validate().ToString());
            }
            */
            var updated = Repository.Update(entity);
            Repository.SaveChanges();
            return Mapper.Map<TEntity, TContract>(Repository.GetById(updated.Id));
        }

        public bool Remove(int id)
        {
            return Repository.Delete(id);
        }

        public void Dispose()
        {
            Repository.Dispose();
        }
    }
}
using System;
using System.Collections.Generic;
using System.Linq;
using Shared.Core;

namespace Backend.Core.Repository
{
    public interface IRepository<TEntity> : IDisposable where TEntity : class, IHasId
    {
        TEntity GetById(int id);
        IQueryable<TEntity> GetAll();
        // IQueryable<TEntity> GetAllPaged(int page, int numberOfItemsOnPage);
        TEntity Add(TEntity entity);
        IQueryable<TEntity> AddAll(IQueryable<TEntity> entities);
        TEntity Update(TEntity entity);
        int SaveChanges();
        TEntity Delete(TEntity entity);
        bool Delete(int id);
    }
}
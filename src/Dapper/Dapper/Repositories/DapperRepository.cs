using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Dapper;
using Dapper.Contrib.Extensions;
using GoldenEye.Backend.Core.Dapper.Generators;
using GoldenEye.Backend.Core.Exceptions;
using GoldenEye.Backend.Core.Repositories;
using GoldenEye.Shared.Core.Extensions.Basic;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.Dapper.Repositories
{
    public class DapperRepository<TEntity>: IRepository<TEntity>
        where TEntity : class, IHaveId
    {
        private readonly IDapperSqlGenerator dapperSqlGenerator;
        private readonly IDbConnection dbConnection;

        public DapperRepository(IDbConnection dbConnection, IDapperSqlGenerator dapperSqlGenerator = null)
        {
            this.dbConnection = dbConnection ?? throw new ArgumentNullException(nameof(dbConnection));
            this.dapperSqlGenerator = dapperSqlGenerator;
        }


        public TEntity FindById(object id)
        {
            if (id == null)
                throw new ArgumentNullException("Id needs to have value");

            var sql = dapperSqlGenerator?.GetById<TEntity>(id);

            return !sql.IsNullOrEmpty()
                ? dbConnection.QuerySingleOrDefault<TEntity>(sql, new {Id = id})
                : dbConnection.Get<TEntity>(id);
        }

        public async Task<TEntity> FindByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            if (id == null)
                throw new ArgumentNullException("Id needs to have value");


            var sql = dapperSqlGenerator?.GetById<TEntity>(id);

            if (!sql.IsNullOrEmpty())
                return (await dbConnection.QuerySingleOrDefaultAsync<TEntity>(sql, new {Id = id}));
            return await dbConnection.GetAsync<TEntity>(id);
        }

        public TEntity GetById(object id)
        {
            return FindById(id) ?? throw NotFoundException.For<TEntity>(id);
        }

        public async Task<TEntity> GetByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            var entity = await FindByIdAsync(id, cancellationToken);

            return entity ?? throw NotFoundException.For<TEntity>(id);
        }

        public IQueryable<TEntity> Query()
        {
            var sql = dapperSqlGenerator?.Query<TEntity>();

            return !sql.IsNullOrEmpty()
                ? dbConnection.Query<TEntity>(sql).AsQueryable()
                : dbConnection.GetAll<TEntity>().AsQueryable();
        }

        public IReadOnlyCollection<TEntity> Query(string query, params object[] queryParams)
        {
            if (query == null)
                throw new ArgumentNullException(nameof(query));

            if (queryParams == null)
                throw new ArgumentNullException(nameof(queryParams));

            return dbConnection.Query<TEntity>(query, queryParams.First()).ToList();
        }

        public async Task<IReadOnlyCollection<TEntity>> QueryAsync(string query,
            CancellationToken cancellationToken = default, params object[] queryParams)
        {
            if (query == null)
                throw new ArgumentNullException(nameof(query));

            if (queryParams == null)
                throw new ArgumentNullException(nameof(queryParams));

            return (await dbConnection.QueryAsync<TEntity>(query, queryParams.First())).ToList();
        }

        public TEntity Add(TEntity entity)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var sql = dapperSqlGenerator?.Add(entity);

            if (!sql.IsNullOrEmpty())
                dbConnection.Execute(sql, entity);
            else
                dbConnection.Insert(entity);

            return entity;
        }

        public async Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var sql = dapperSqlGenerator?.Add(entity);

            if (!sql.IsNullOrEmpty())
                await dbConnection.ExecuteAsync(sql, entity);
            else
                await dbConnection.InsertAsync(entity);

            return entity;
        }

        public IReadOnlyCollection<TEntity> AddAll(params TEntity[] entities)
        {
            return entities.Select(Add).ToList();
        }

        public async Task<IReadOnlyCollection<TEntity>> AddAllAsync(CancellationToken cancellationToken = default,
            params TEntity[] entities)
        {
            var result = new List<TEntity>();
            foreach (var entity in entities) result.Add(await AddAsync(entity, cancellationToken));

            return result;
        }

        public TEntity Update(TEntity entity)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var sql = dapperSqlGenerator?.Update(entity);

            if (!sql.IsNullOrEmpty())
                dbConnection.Execute(sql, entity);
            else
                dbConnection.Update(entity);

            return entity;
        }

        public async Task<TEntity> UpdateAsync(TEntity entity, CancellationToken cancellationToken = default)
        {
            var sql = dapperSqlGenerator?.Update(entity);

            if (!sql.IsNullOrEmpty())
                await dbConnection.ExecuteAsync(sql, entity);
            else
                await dbConnection.UpdateAsync(entity);

            return entity;
        }

        public TEntity Delete(TEntity entity)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var sql = dapperSqlGenerator?.Delete(entity);

            if (!sql.IsNullOrEmpty())
                dbConnection.Execute(sql, entity);
            else
                dbConnection.Delete(entity);
            return entity;
        }

        public async Task<TEntity> DeleteAsync(TEntity entity, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var sql = dapperSqlGenerator?.Delete(entity);

            if (!sql.IsNullOrEmpty())
                await dbConnection.ExecuteAsync(sql, entity);
            else
                await dbConnection.DeleteAsync(entity);
            return entity;
        }

        public bool DeleteById(object id)
        {
            if (id == null)
                throw new ArgumentNullException(nameof(id));

            var sql = dapperSqlGenerator?.Delete(id);

            if (!sql.IsNullOrEmpty())
                dbConnection.Execute(sql, id);
            else
                throw new NotImplementedException();

            return true;
        }

        public async Task<bool> DeleteByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            if (id == null)
                throw new ArgumentNullException(nameof(id));

            var sql = dapperSqlGenerator?.Delete(id);

            if (!sql.IsNullOrEmpty())
                await dbConnection.ExecuteAsync(sql, id);
            else
                throw new NotImplementedException();

            return true;
        }

        public void SaveChanges()
        {
            //TODO: Add UnitOfWork
        }

        public Task SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            //TODO: Add UnitOfWork
            return Task.CompletedTask;
        }
    }
}

using System;
using System.Data;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Dapper;
using Dapper.Contrib.Extensions;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers;
using GoldenEye.Backend.Core.Dapper.Generators;
using GoldenEye.Shared.Core.Extensions.Basic;

namespace GoldenEye.Backend.Core.Dapper.Context
{
    public class DapperDataContext: IDataContext
    {
        private readonly IDbConnection dbConnection;
        private readonly IDapperSqlGenerator dapperSqlGenerator;
        private bool wasDisposed;

        public DapperDataContext(IDbConnection dbConnection, IDapperSqlGenerator dapperSqlGenerator = null)
        {
            this.dbConnection = dbConnection ?? throw new ArgumentNullException(nameof(dbConnection));
            this.dapperSqlGenerator = dapperSqlGenerator;
        }

        public TEntity Add<TEntity>(TEntity entity) where TEntity : class
        {
            var sql = dapperSqlGenerator?.Add(entity);

            if (!sql.IsNullOrEmpty())
            {
                dbConnection.Execute(sql, entity);
            }
            else
            {
                dbConnection.Insert(entity);
            }

            return entity;
        }

        public async Task<TEntity> AddAsync<TEntity>(TEntity entity, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class
        {
            var sql = dapperSqlGenerator?.Add(entity);

            if (!sql.IsNullOrEmpty())
            {
                await dbConnection.ExecuteAsync(sql, entity);
            }
            else
            {
                await dbConnection.InsertAsync(entity);
            }

            return entity;
        }

        public IQueryable<TEntity> AddRange<TEntity>(params TEntity[] entities) where TEntity : class
        {
            return entities.Select(entity => Add(entity)).AsQueryable();
        }

        public void Dispose()
        {
            if (wasDisposed)
                return;

            wasDisposed = true;
            GC.SuppressFinalize(this);
        }

        public TEntity GetById<TEntity>(object id) where TEntity : class, new()
        {
            var sql = dapperSqlGenerator?.GetById<TEntity>(id);

            if (!sql.IsNullOrEmpty())
            {
                return dbConnection.Query<TEntity>(sql, new { Id = id }).SingleOrDefault();
            }
            else
            {
                return dbConnection.Get<TEntity>(id);
            }
        }

        public async Task<TEntity> GetByIdAsync<TEntity>(object id, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class, new()
        {
            var sql = dapperSqlGenerator?.GetById<TEntity>(id);

            if (!sql.IsNullOrEmpty())
            {
                return (await dbConnection.QueryAsync<TEntity>(sql, new { Id = id })).SingleOrDefault();
            }
            else
            {
                return await dbConnection.GetAsync<TEntity>(id);
            }
        }

        public IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class
        {
            var sql = dapperSqlGenerator?.Query<TEntity>();

            if (!sql.IsNullOrEmpty())
            {
                return dbConnection.Query<TEntity>(sql).AsQueryable();
            }
            else
            {
                return dbConnection.GetAll<TEntity>().AsQueryable();
            }
        }

        public IQueryable<TEntity> CustomQuery<TEntity>(string query) where TEntity : class
        {
            return dbConnection.Query<TEntity>(query).AsQueryable();
        }

        public TEntity Remove<TEntity>(TEntity entity, int? version = null) where TEntity : class
        {
            var sql = dapperSqlGenerator?.Delete(entity);

            if (!sql.IsNullOrEmpty())
            {
                dbConnection.Execute(sql, entity);
            }
            else
            {
                dbConnection.Delete(entity);
            }
            return entity;
        }

        public bool Remove<TEntity>(object id, int? version = null) where TEntity : class
        {
            var sql = dapperSqlGenerator?.Delete(id);

            if (!sql.IsNullOrEmpty())
            {
                dbConnection.Execute(sql, id);
            }
            else
            {
                throw new NotImplementedException();
            }
            return true;
        }

        public async Task<TEntity> RemoveAsync<TEntity>(TEntity entity, int? version = null, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class
        {
            var sql = dapperSqlGenerator?.Delete(entity);

            if (!sql.IsNullOrEmpty())
            {
                await dbConnection.ExecuteAsync(sql, entity);
            }
            else
            {
                await dbConnection.DeleteAsync(entity);
            }
            return entity;
        }

        public Task<bool> RemoveAsync<TEntity>(object id, int? version = null, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class
        {
            throw new NotImplementedException();
        }

        public int SaveChanges()
        {
            SaveChangesProcessor.Instance.RunAll(this);
            return 0;
        }

        public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default(CancellationToken))
        {
            SaveChangesProcessor.Instance.RunAll(this);
            return Task.FromResult(0);
        }

        public TEntity Update<TEntity>(TEntity entity, int? version = null) where TEntity : class
        {
            var sql = dapperSqlGenerator?.Update(entity);

            if (!sql.IsNullOrEmpty())
            {
                dbConnection.Execute(sql, entity);
            }
            else
            {
                dbConnection.Update(entity);
            }

            return entity;
        }

        public async Task<TEntity> UpdateAsync<TEntity>(TEntity entity, int? version = null, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class
        {
            var sql = dapperSqlGenerator?.Update(entity);

            if (!sql.IsNullOrEmpty())
            {
                await dbConnection.ExecuteAsync(sql, entity);
            }
            else
            {
                await dbConnection.UpdateAsync(entity);
            }

            return entity;
        }
    }
}

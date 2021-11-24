using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Dapper;
using Dapper.Contrib.Extensions;
using GoldenEye.Dapper.Generators;
using GoldenEye.Dapper.Mappings;
using GoldenEye.Events;
using GoldenEye.Events.Aggregate;
using GoldenEye.Extensions.Basic;
using GoldenEye.Objects.General;
using GoldenEye.Repositories;

namespace GoldenEye.Dapper.Repositories;

public class DapperRepository<TEntity>: IRepository<TEntity>
    where TEntity : class, IHaveId
{
    private readonly IDapperSqlGenerator dapperSqlGenerator;
    private readonly IDbConnection dbConnection;
    private readonly IAggregateEventsPublisher aggregateEventsPublisher;

    public DapperRepository(IDbConnection dbConnection, IAggregateEventsPublisher aggregateEventsPublisher, IDapperSqlGenerator dapperSqlGenerator = null)
    {
        this.dbConnection = dbConnection ?? throw new ArgumentNullException(nameof(dbConnection));
        this.aggregateEventsPublisher = aggregateEventsPublisher;
        this.dapperSqlGenerator = dapperSqlGenerator;
    }

    public async Task<TEntity> FindById(object id, CancellationToken cancellationToken = default)
    {
        if (id == null)
            throw new ArgumentNullException(nameof(id), "Id needs to have value");

        var sql = dapperSqlGenerator?.FindById<TEntity>(id);

        if (!sql.IsNullOrEmpty())
            return (await dbConnection.QuerySingleOrDefaultAsync<TEntity>(sql, new {Id = id}));

        return await dbConnection.GetAsync<TEntity>(id);
    }

    public IQueryable<TEntity> Query()
    {
        var sql = dapperSqlGenerator?.Query<TEntity>();

        return !sql.IsNullOrEmpty()
            ? dbConnection.Query<TEntity>(sql).AsQueryable()
            : dbConnection.GetAll<TEntity>().AsQueryable();
    }

    public async Task<IReadOnlyCollection<TEntity>> RawQuery(string query,
        CancellationToken cancellationToken, params object[] queryParams)
    {
        if (query == null)
            throw new ArgumentNullException(nameof(query));

        if (queryParams == null)
            throw new ArgumentNullException(nameof(queryParams));

        return (await dbConnection.QueryAsync<TEntity>(query, queryParams.First())).ToList();
    }

    public async Task<TEntity> Add(TEntity entity, CancellationToken cancellationToken = default)
    {
        if (entity == null)
            throw new ArgumentNullException(nameof(entity));

        var sql = dapperSqlGenerator?.Add(entity);

        if (!sql.IsNullOrEmpty())
            await dbConnection.ExecuteAsync(sql, entity);
        else
            await dbConnection.InsertAsync(entity);

        aggregateEventsPublisher.TryEnqueueEventsFrom(entity, out _);

        return entity;
    }

    public async Task<TEntity> Update(TEntity entity, int? expectedVersion, CancellationToken cancellationToken = default)
    {
        if(expectedVersion.HasValue)
            throw new NotImplementedException();

        if (entity == null)
            throw new ArgumentNullException(nameof(entity));

        var sql = dapperSqlGenerator?.Update(entity);

        if (!sql.IsNullOrEmpty())
            await dbConnection.ExecuteAsync(sql, entity);
        else
            await dbConnection.UpdateAsync(entity);

        aggregateEventsPublisher.TryEnqueueEventsFrom(entity, out _);

        return entity;
    }

    public async Task<TEntity> Delete(TEntity entity, int? expectedVersion, CancellationToken cancellationToken = default)
    {
        if(expectedVersion.HasValue)
            throw new NotImplementedException();

        if (entity == null)
            throw new ArgumentNullException(nameof(entity));

        var sql = dapperSqlGenerator?.Delete(entity);

        if (!sql.IsNullOrEmpty())
            await dbConnection.ExecuteAsync(sql, entity);
        else
            await dbConnection.DeleteAsync(entity);

        aggregateEventsPublisher.TryEnqueueEventsFrom(entity, out _);

        return entity;
    }

    public async Task<bool> DeleteById(object id, int? expectedVersion, CancellationToken cancellationToken = default)
    {
        if(expectedVersion.HasValue)
            throw new NotImplementedException();

        if (id == null)
            throw new ArgumentNullException(nameof(id));

        var sql = dapperSqlGenerator?.Delete(id);

        if (!sql.IsNullOrEmpty())
            await dbConnection.ExecuteAsync(sql, id);
        else
            throw new NotImplementedException($"{nameof(DeleteById)} by convention is not supported - please provide sql script through {nameof(IDapperMapping)}");

        return true;
    }

    public Task SaveChanges(CancellationToken cancellationToken = default)
    {
        return aggregateEventsPublisher.Publish(cancellationToken);
    }
}

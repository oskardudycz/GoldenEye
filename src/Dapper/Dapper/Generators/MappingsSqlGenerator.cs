using System.Collections.Generic;
using System.Linq;
using GoldenEye.Dapper.Mappings;

namespace GoldenEye.Dapper.Generators;

/// <summary>
///     Generates Dapper sql from mappings
/// </summary>
public class MappingsSqlGenerator: IDapperSqlGenerator
{
    private readonly IReadOnlyCollection<IDapperMapping> mappings;

    public MappingsSqlGenerator(IReadOnlyCollection<IDapperMapping> mappings)
    {
        this.mappings = mappings ?? new List<IDapperMapping>();
    }

    public string Add<TEntity>(TEntity entity)
    {
        return mappings.OfType<IDapperMapping<TEntity>>().FirstOrDefault()?.Add;
    }

    public string Update<TEntity>(TEntity entity)
    {
        return mappings.OfType<IDapperMapping<TEntity>>().FirstOrDefault()?.Update;
    }

    public string Delete<TEntity>(TEntity entity)
    {
        return mappings.OfType<IDapperMapping<TEntity>>().FirstOrDefault()?.Delete;
    }

    public string Delete<TEntity>(object id)
    {
        return mappings.OfType<IDapperMapping<TEntity>>().FirstOrDefault()?.Delete;
    }

    public string Query<TEntity>()
    {
        return mappings.OfType<IDapperMapping<TEntity>>().FirstOrDefault()?.Query;
    }

    public string FindById<TEntity>(object id)
    {
        return mappings.OfType<IDapperMapping<TEntity>>().FirstOrDefault()?.FindById;
    }
}
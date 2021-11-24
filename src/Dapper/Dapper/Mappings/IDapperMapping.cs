namespace GoldenEye.Dapper.Mappings;

public interface IDapperMapping
{
    string Add { get; }
    string Update { get; }
    string Delete { get; }
    string Query { get; }
    string FindById { get; }
}

public interface IDapperMapping<TEntity>: IDapperMapping
{
}
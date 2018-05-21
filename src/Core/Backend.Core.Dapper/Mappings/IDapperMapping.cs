namespace GoldenEye.Backend.Core.Dapper.Mappings
{
    public interface IDapperMapping
    {
        string Add { get; }
        string Update { get; }
        string Delete { get; }
        string Query { get; }
        string GetById { get; }
    }

    public interface IDapperMapping<TEntity> : IDapperMapping
    {
    }
}
namespace GoldenEye.Dapper.Generators;

public interface IDapperSqlGenerator
{
    string Add<TEntity>(TEntity entity);

    string Update<TEntity>(TEntity entity);

    string Delete<TEntity>(TEntity entity);

    string Delete<TEntity>(object id);

    string FindById<TEntity>(object id);

    string Query<TEntity>();
}
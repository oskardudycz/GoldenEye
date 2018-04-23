using System.Collections.Generic;
using System.Linq;
using GoldenEye.Backend.Core.Dapper.Mappings;

namespace GoldenEye.Backend.Core.Dapper.Generators
{
    public class DapperSqlGenerator : IDapperSqlGenerator
    {
        private readonly IReadOnlyCollection<IDapperMapping> mappings;

        public DapperSqlGenerator(IReadOnlyCollection<IDapperMapping> mappings)
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

        public string Query<TEntity>()
        {
            return mappings.OfType<IDapperMapping<TEntity>>().FirstOrDefault()?.Query;
        }

        public string GetById<TEntity>(object id)
        {
            return mappings.OfType<IDapperMapping<TEntity>>().FirstOrDefault()?.GetById;
        }
    }
}
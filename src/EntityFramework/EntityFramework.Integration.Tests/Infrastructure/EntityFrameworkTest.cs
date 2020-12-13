using System;
using System.Data;
using Npgsql;

namespace Backend.Core.EntityFramework.Integration.Tests.Infrastructure
{
    public class EntityFrameworkTest : IDisposable
    {
        public string ConnectionString
        {
            get =>
                $"PORT = 5432; HOST = 127.0.0.1; TIMEOUT = 15; POOLING = True; MINPOOLSIZE = 1; MAXPOOLSIZE = 100; COMMANDTIMEOUT = 20; DATABASE = 'postgres'; PASSWORD = 'Password12!'; USER ID = 'postgres'"
            ;
        }

        protected readonly string SchemaName = "eftest_users";

        protected EntityFrameworkTest()
        {
            Execute( $"CREATE SCHEMA IF NOT EXISTS {SchemaName};");
        }

        public void Dispose()
        {
            Execute($"DROP SCHEMA {SchemaName} CASCADE;");
        }

        private void Execute(string sql)
        {
            using var conn = new NpgsqlConnection(ConnectionString);
            conn.Open();
            using var tran = conn.BeginTransaction(IsolationLevel.ReadCommitted);
            var command = conn.CreateCommand();
            command.CommandText = sql;

            command.ExecuteNonQuery();

            tran.Commit();
        }

        protected static string GenerateSchemaName() => "sch" + Guid.NewGuid().ToString().Replace("-", string.Empty);

    }
}

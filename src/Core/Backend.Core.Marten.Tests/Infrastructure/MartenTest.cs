using System;
using System.Data;
using GoldenEye.Backend.Core.Marten.Registration;
using Marten.Events;
using Npgsql;

namespace Marten.Integration.Tests.TestsInfrasructure
{
    public abstract class MartenTest : IDisposable
    {
        protected readonly IDocumentSession Session;

        protected IEventStore EventStore => Session.Events;

        protected readonly string SchemaName = GenerateSchemaName();

        public static string ConnectionString =
            "PORT = 5432; HOST = 127.0.0.1; TIMEOUT = 15; POOLING = True; MINPOOLSIZE = 1; MAXPOOLSIZE = 100; COMMANDTIMEOUT = 20; DATABASE = 'postgres'; PASSWORD = 'Password12!'; USER ID = 'postgres'";

        protected static string GenerateSchemaName() => "sch" + Guid.NewGuid().ToString().Replace("-", string.Empty);

        protected MartenTest() : this(true)
        {
        }

        protected MartenTest(bool shouldCreateSession)
        {
            if (shouldCreateSession)
                Session = CreateSession();
        }

        protected virtual IDocumentSession CreateSession(Action<StoreOptions> storeOptions = null)
        {
            var documentStore = Registration.CreateDocumentStore(ConnectionString, storeOptions, SchemaName);

            return Registration.CreateDocumentSession(documentStore);
        }

        public void Dispose()
        {
            Session?.Dispose();

            var sql = $"DROP SCHEMA {SchemaName} CASCADE;";
            using (var conn = new NpgsqlConnection(ConnectionString))
            {
                conn.Open();
                using (var tran = conn.BeginTransaction(IsolationLevel.ReadCommitted))
                {
                    var command = conn.CreateCommand();
                    command.CommandText = sql;

                    command.ExecuteNonQuery();

                    tran.Commit();
                }
            }
        }
    }
}
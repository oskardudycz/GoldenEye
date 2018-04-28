using Dapper.Contrib.Extensions;

namespace Backend.Core.Dapper.Integration.Tests.TestData
{
    public static class Structure
    {
        public static string UsersCreateSql =
            "CREATE TABLE IF NOT EXISTS \"users\" (" +
            "   \"id\"             SERIAL    PRIMARY KEY," +
            "   \"UserName\"       TEXT      NOT NULL," +
            "   \"FullName\"       TEXT" +
            ");";
    }

    public class User
    {
        [Key]
        public int Id { get; set; }

        public string UserName { get; set; }
        public string FullName { get; set; }
    }
}
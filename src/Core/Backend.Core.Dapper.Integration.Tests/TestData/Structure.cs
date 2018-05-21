using Dapper.Contrib.Extensions;

namespace Backend.Core.Dapper.Integration.Tests.TestData
{
    public static class Structure
    {
        public static string UsersCreateSql =
            @"IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'Users')
            BEGIN
                CREATE TABLE [Users] (
                   [Id]             INT              NOT NULL    IDENTITY(1,1)    PRIMARY KEY,
                   [UserName]       NVARCHAR(MAX)    NOT NULL,
                   [FullName]       NVARCHAR(MAX)
                );
            END;";
    }

    public class User
    {
        [Key]
        public int Id { get; set; }

        public string UserName { get; set; }
        public string FullName { get; set; }
    }
}
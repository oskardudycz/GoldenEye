using System.Collections.Generic;

namespace Tickets.Api.Tests.Config;

public static class TestConfiguration
{
    public static Dictionary<string, string> Get(string fixtureName) =>
        new()
        {
            {
                "Marten:ConnectionString",
                "PORT = 5432; HOST = localhost; TIMEOUT = 15; POOLING = True; MINPOOLSIZE = 1; MAXPOOLSIZE = 100; COMMANDTIMEOUT = 20; DATABASE = 'postgres'; PASSWORD = 'Password12!'; USER ID = 'postgres'"
            },
            {"Marten:WriteModelSchema", $"{fixtureName}_write"},
            {"Marten:ReadModelSchema", $"{fixtureName}_read"},
            {"Marten:ShouldRecreateDatabase", "true"}
        };
}
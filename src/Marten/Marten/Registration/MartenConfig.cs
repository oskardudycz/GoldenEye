namespace GoldenEye.Marten.Registration;

public class MartenConfig
{
    public const string DefaultConfigKey = "Marten";

    public const string DefaultSchema = "public";

    public string ConnectionString { get; set; }

    public string WriteModelSchema { get; set; } = DefaultSchema;

    public string ReadModelSchema { get; set; } = DefaultSchema;

    public bool ShouldRecreateDatabase { get; set; } = false;
}
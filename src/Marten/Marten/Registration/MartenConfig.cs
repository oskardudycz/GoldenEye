using Marten.Events.Daemon.Resiliency;

namespace GoldenEye.Marten.Registration;

public class MartenConfig
{

    private const string DefaultSchema = "public";

    public string ConnectionString { get; set; } = default!;

    public string WriteModelSchema { get; set; } = DefaultSchema;
    public string ReadModelSchema { get; set; } = DefaultSchema;

    public bool ShouldRecreateDatabase { get; set; } = false;

    public DaemonMode DaemonMode { get; set; } = DaemonMode.Disabled;
}

namespace GoldenEye.Shared.Core.Objects.Audit
{
    public interface IHasManuallyUpdatedField
    {
        bool WasManuallyUpdated { get; set; }
    }
}

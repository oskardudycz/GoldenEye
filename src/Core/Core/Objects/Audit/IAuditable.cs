using System;

namespace GoldenEye.Objects.Audit;

public interface IAuditable
{
    DateTime Created { get; set; }
    int? CreatedBy { get; set; }
    DateTime? LastModified { get; set; }
    int? LastModifiedBy { get; set; }
}
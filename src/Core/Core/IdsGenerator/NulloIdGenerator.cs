using System;

namespace GoldenEye.IdsGenerator;

public class NulloIdGenerator : IIdGenerator
{
    public Guid New() => Guid.NewGuid();
}

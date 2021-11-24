using System;

namespace GoldenEye.IdsGenerator;

public interface IIdGenerator
{
    Guid New();
}
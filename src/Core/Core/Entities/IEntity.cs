using System;
using GoldenEye.Objects.General;

namespace GoldenEye.Entities;

public interface IEntity<out TKey>: IHaveId<TKey>
{
}
public interface IEntity: IEntity<Guid>
{
}
using System.Data.Entity;
using GoldenEye.Backend.Core.Context;
using $rootnamespace$.Entities;

namespace $rootnamespace$.Context
{
    public interface ISampleContext: IDataContext
    {
        IDbSet<TaskEntity> Tasks { get; }
    }
}
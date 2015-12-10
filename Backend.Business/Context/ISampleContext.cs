using System.Data.Entity;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Core.Context;

namespace GoldenEye.Backend.Business.Context
{
    public interface ISampleContext: IDataContext
    {
        IDbSet<TaskEntity> Tasks { get; }
        IDbSet<TaskTypeEntity> TaskTypes { get; }
        IDbSet<Customer> Customers { get; }
    }
}
using System.Data.Entity;
using GoldenEye.Backend.Core.Context;
using GoldenEye.SPA.Business.Sample.Entities;

namespace GoldenEye.SPA.Business.Sample.Context
{
    public interface ISampleContext: IDataContext
    {
        IDbSet<TaskEntity> Tasks { get; }
    }
}
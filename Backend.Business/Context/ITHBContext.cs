using System;
using Backend.Core.Context;
using Backend.Business.Entities;
using System.Data.Entity;

namespace Backend.Business.Context
{
    public interface ITHBContext: IDataContext
    {
        IDbSet<Task> Tasks { get; set; }
        IDbSet<TaskTypeEntity> TaskTypes { get; set; }
    }
}
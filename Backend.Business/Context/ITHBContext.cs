using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Backend.Core.Context;
using Backend.Business.Entities;
using System.Data.Entity;

namespace Backend.Business.Context
{
    public interface ITHBContext: IDataContext, IDisposable
    {
        IDbSet<TaskEntity> Tasks { get; set; }
    }
}
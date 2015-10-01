using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Backend.Core.Context;
using Backend.Business.Entities;
using System.Data.Entity;

namespace Backend.Business.Context
{
    public class THBContext: DataContext<THBContext>, ITHBContext
    {
        public IDbSet<TaskEntity> Tasks { get; set; }
    }
}
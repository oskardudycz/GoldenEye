using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Backend.Core.Repository;
using Backend.Business.Entities;
using Backend.Business.Context;

namespace Backend.Business.Repository
{
    public class TaskTypeRepository : BaseRepository<TaskTypeEntity>, ITaskTypeRepository
    {
        private readonly ITHBContext _taskContext;

        public TaskTypeRepository(ITHBContext context)
            : base(context, context.TaskTypes)
        {
            _taskContext = context;
        }
    }
}